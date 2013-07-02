MailSender = require '../../lib/mail_sender'
MailGetter = require '../../lib/mail_getter'
async = require('async')
LogMessage = require '../../lib/logmessage'


module.exports = (compound, Mailbox) ->
    {Mail, MailFolder} = compound.models

    # helpers

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

        async.parallel [
            (cb) => Mail.requestDestroy "bymailbox", key: @id, cb
            (cb) => MailFolder.requestDestroy "bymailbox", key: @id, cb
            (cb) => LogMessage.destroy this, cb
            @destroyAccount.bind   this
        ], (err) =>
            @log "destroying finished..."
            @log err if err
            @destroy callback

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
        @getAccount (err, account) =>
            return callback err if err
            callback null, new MailSender this, account.password

    Mailbox::getMailGetter = (callback) ->
        @getAccount (err, account) =>
            return callback err if err
            mg = new MailGetter this, account.password
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

        # no need to initialize import again if it was importing.
        return callback() if @status is "importing"

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
                        MailFolder.create folder, (err, folder) =>
                            # store mailsToBeFetched in the folder
                            folder.setupImport getter, (err) =>
                                @log err if err
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

        @log "Start import"
        @getMailGetter (err, getter)  =>
            return callback err if err

            # List folders in this mailbox
            MailFolder.findByMailbox @id, (err, folders) =>
                return callback err if err

                folders = [] unless folders

                success = 0
                done    = 0
                total   = 0
                oldPercent = 0

                for folder in folders
                    total += folder.mailsToBe?.length or 0

                @log "total mails to import : #{total}"

                # forEachFolder
                async.eachSeries folders, (folder, cb) =>

                    @log "Importing folder #{folder.path}"

                    progressHandler = (curSuccess, curDone, curTotal) =>
                        percent = Math.floor(100 * (done + curDone) / total)
                        if percent isnt oldPercent
                            oldPercent = percent
                            @progress percent

                    # do Import at folder level
                    folder.doImport getter, progressHandler, (err, doneNb) =>
                        done += doneNb
                        @log err if err
                        cb() #do not pass error to keep looping

                , (err) =>

                    getter.logout (err) =>
                        @log err if err

                        # change mailbox state
                        @importSuccessfull (err) =>
                            @log err if err

                            callback()

    # dry function : setup import then do it immediately
    Mailbox::fullImport = (callback) ->
        @setupImport (err) =>
            if err
                @log err
                callback err
            else
                @doImport callback

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
