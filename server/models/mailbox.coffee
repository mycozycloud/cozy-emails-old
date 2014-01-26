queue = require '../lib/queue'
async = require 'async'
americano = require('americano-cozy')

Mail = require './mail'
MailFolder = require './mailfolder'
MailSender = require '../lib/mail_sender'
MailGetter = require '../lib/mail_getter'
LogMessage = require '../lib/logmessage'


module.exports = Mailbox = americano.getModel 'Mailbox',

    # identification
    name: String
    config: {type: Number, default: 0}
    newMessages: {type: Number, default: 0}
    createdAt: {type: Date, default: Date}

    # shared credentails for in and out bound
    login: String
    password: String

    # data for outbound mails - SMTP
    smtpServer: String
    smtpSendAs: String
    smtpSsl: {type: Boolean, default: true}
    smtpPort: {type: Number, default: 465}

    # data for inbound mails - IMAP
    imapServer: String
    imapPort: String
    imapSecure: {type: Boolean, default: true}
    imapLastSync: {type: Date, default: 0}
    imapLastFectechDate: {type: Date, default: 0}
    # this one is used to build the query to fetch new mails
    imapLastFetchedId: {type: Number, default: 0}

    # data regarding the interface
    checked: {type: Boolean, default: true}
    # color of the mailbox in the list
    color: {type: String, default: "#0099FF"}
    # status visible for user
    statusMsg: {type: String, default: "Waiting for import"}

    # data for import
    # ready to be fetched for new mail
    activated: {type: Boolean, default: false}
    status: {type: String, default: "freezed"}
    mailsToImport: {type: Number, default: 0}

Mailbox.folderQueues = {}

Mailbox::log = (msg) ->
    console.info "#{@} #{msg?.stack or msg}"

Mailbox::toString = ->
    "[Mailbox #{@name} #{@id}]"


# To ensure unique mailbox
Mailbox.findByEmail = (email, callback) ->
    Mailbox.request 'byEmail', key: email, (err, boxes) ->
        if err then callback err
        else callback null, (boxes[0] or null)

# Delete mailbox and everthing related
Mailbox::remove = (callback) ->
    @log "destroying box..."

    async.series [
        (cb) => Mail.requestDestroy "bymailbox", key: @id, cb
        (cb) => MailFolder.requestDestroy "bymailbox", key: @id, cb
        (cb) => LogMessage.destroy this, cb
    ], (err) =>
        @log "destroying finished..."
        @log err if err
        @destroy callback

Mailbox::reset = (callback) ->

    async.parallel [
        (cb) => Mail.requestDestroy "bymailbox", key: @id, cb
        (cb) => MailFolder.requestDestroy "bymailbox", key: @id, cb
        (cb) => LogMessage.destroy this, cb
    ], (err) =>
        @log "reset finished..."
        if err
            @log err
            callback err
        else
            callback()


Mailbox::importStarted = (callback) ->
    data =
        status: "import_preparing"
        statusMsg: "import started"

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createImportStartedInfo this, callback

# Mark import as successfull and stores a notification message about it.
Mailbox::importSuccessfull = (callback) ->
    data =
        status: "imported"
        statusMsg: "import complete"

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createImportSuccess this, callback


# Mark import as failed and stores a notification message about it.
Mailbox::importFailed = (err, callback) ->
    @log err

    data =
        status: "import_failed"
        statusMsg: "import failed" + err.message

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createImportFailed this, callback

# Update box status with given progress and stores a notification about it.
Mailbox::progress = (progress, callback) ->
    return if @status is 'imported'
    data =
        status: "importing"
        statusMsg: "importing #{progress} %"

    @updateAttributes data, (error) =>
        LogMessage.createImportProgressInfo @, progress, callback


Mailbox::getMailSender = (callback) ->
    callback null, new MailSender this, @password

Mailbox::getMailGetter = (callback) ->
    mg = new MailGetter this, @password
    mg.connect (err) ->
        if err then callback err
        else callback null, mg

# Send a mail by using smpt server set in the configuration of the current
# mailbox.
Mailbox::sendMail = (data, callback) ->
    @getMailSender (err, sender) ->
        return callback err if err
        sender.sendMail data (err) ->
            if err
                @log "Sending mail failed"
                callback err
            else
                @log "Message sent successfully!"
                callback()


# Prepare import of current mailbox. Grab and store all ids that should be
# retrieved. This is useful in case of crash if the import should be start
# again.
Mailbox::setupImport = (callback) ->

    # change mailbox state
    @importStarted =>

        # get connected getter
        @getMailGetter (err, getter) =>
            return @importFailed err, callback if err

            # list folders in remote account
            getter.listFolders (err, folders) =>
                return @importFailed err, callback if err

                folder.mailbox = @id for folder in folders

                setupImportOneFolder = (folder, cb) =>
                    if folder.path isnt "[Gmail]/All Mail"
                        MailFolder.create folder, (err, folder) =>
                            # store mailsToBeFetched in the folder
                            folder.setupImport getter, (err) =>
                                @log err if err
                                cb()
                    else
                        cb()

                # Import each folder
                async.eachSeries folders, setupImportOneFolder, (err) =>

                    data =
                        activated: true
                        status: "importing"

                    @updateAttributes data, (err) =>
                        return @importFailed err, callback if err

                        # disconnect from server
                        getter.logout callback


# Run the real import grab all mailtobes from database and fetch message one by
# one based on this list.
Mailbox::doImport = (callback = ->) ->
    Mailbox.folderQueues[@id] = {}

    @log "Start import"
    @getMailGetter (err, getter)  =>
        return callback err if err

        # List folders in this mailbox
        MailFolder.findByMailbox @id, (err, folders) =>
            return @manageErr err, callback if err

            folders = [] unless folders
            total = 0

            # Total number of emails

            for folder in folders
                total += folder.mailsToBe?.length or 0

            @log "total mails to import: #{total}"

            # Progress manager
            percent = 0
            oldPercent = 0
            done = 0
            progressHandler = =>
                done++
                percent = Math.floor(100 * (done) / total)
                if percent isnt oldPercent
                    oldPercent = percent
                    @progress percent

            for folder in folders

                Mailbox.folderQueues[@id][folder.id] = folder.pushFetchTasks(
                    getter, progressHandler
                )

            async.eachSeries folders, (folder, cb) =>
                @log 'import:' + folder.id
                @log 'import:' + folder.name

                if folder.mailsToBe?.length > 0
                    getter.openBox folder.path, (err) =>
                        return @manageErr err, cb if err
                        Mailbox.folderQueues[@id][folder.id].on 'success', ->
                            progressHandler()

                        Mailbox.folderQueues[@id][folder.id].run (err) =>
                            return @manageErr err, cb if err

                            getter.closeBox (err) =>
                                return @manageErr err, cb if err
                                cb()
                else cb()

            , (error) =>
                Mailbox.folderQueues[@id] = {}
                if error
                    @log 'An error occured while importing mails'
                    console.log error
                    callback error, done

                else
                    async.eachSeries folders, (folder, cb) =>
                        folder.updateAttributes mailsToBe: null, (err) =>
                            @log err if err
                            cb null, done
                    , (err) =>
                        return @manageErr err, callback if err

                        getter.logout (err) =>
                            return @manageErr err, callback if err

                            @importSuccessfull (err) =>
                                return @manageErr err, callback if err
                                callback()

Mailbox::manageErr = (err, callback) ->
    @log err
    callback err

# dry function : setup import then do it immediately
Mailbox::fullImport = (callback) ->
    @setupImport (err) =>
        if err
            @log err
            callback err
        else
            @doImport callback

Mailbox::stopImport = (callback = ->) ->
    for folder, queue of Mailbox.folderQueues[@id]
        if queue?.empty?
            queue.empty()
    callback()
        #recClean = =>
            #if queues.length > 0
                #queue = queues.pop()
                #recEmpty = ->
                    #queue.empty()
                    #if queue.isRunning
                        #process.nextTick recEmpty
                    #else
                        #recClean()
                #recEmpty()
            #else
                #@queues = {}
        #recClean()

# Synchronize one mail after it have been changed on cozy side
# Open a connection, delegate sync to folder, close connection
Mailbox::syncOneMail = (mail, newflags, callback) ->
    @getMailGetter (err, getter) ->
        return callback err if err

        MailFolder.find mail.folder, (err, folder) ->
            return callback err if err

            folder.syncOneMail getter, mail, newflags, (err, folder) ->
                return callback err if err

                getter.logout (err) ->
                    return callback err if err

                    callback null, folder
