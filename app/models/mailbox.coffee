MailSender = require '../../lib/mail_sender'
MailGetter = require '../../lib/mail_getter'
async = require('async')
NotificationHelper = require('cozy-notifications-helper')
Notifications = new NotificationHelper('mails')


module.exports = (compound, Mailbox) ->
    {Mail, MailToBe, Folder, Attachment, LogMessage} = compound.models

    # helpers

    Mailbox::log = (msg) ->
        console.info "#{@} #{msg?.stack or msg}"

    Mailbox::toString = ->
        "[Mailbox #{@name} #{@id}]"

    Mailbox.findByEmail = (email, callback) ->
        Mailbox.request 'byEmail', key: email, (err, boxes) ->
            console.log boxes

            if err then callback err
            else if boxes?.length is 0
                callback null, null
            else
                callback null, boxes[0]


    # Destroy helpers

    # Delete mailbox and everthing related mails, mailToBes, attachments,
    # accounts...
    Mailbox::remove = (callback) ->
        @log "destroying box..."

        # Destroy Notifications
        Notifications.destroy "newmail-#{@id}"
        Notifications.destroy "download-#{@id}"
        Notifications.destroy "importprogress-#{@id}"

        async.parallel [
            (cb) => Mail.requestDestroy "bymailbox", key: @id, cb
            (cb) => Attachment.requestDestroy "bymailbox", key: @id, cb
            (cb) => Folder.requestDestroy "bymailbox", key: @id, cb
            @destroyMailsToBe.bind this
            @destroyAccount.bind   this
        ], (err) =>
            @log "destroying finished..."
            @log err if err
            @destroy callback

    # Destroy mails linked to current mailbox
    Mailbox::destroyMails = (callback) ->
        Mail.requestDestroy "bymailbox", key: @id, callback

    # Destroy attachments linked to current mailbox
    Mailbox::destroyAttachments = (callback) ->
        Attachment.requestDestroy "bymailbox", key: @id, callback

    # Destroy mail to bes linked to current mailbox
    Mailbox::destroyMailsToBe = (callback) ->
        params =
            startkey: [@id]
            endkey: [@id + "0"]
        MailToBe.requestDestroy "bymailbox", params, callback

    # Mark last fetched date to current mailbox and store a notification about it.
    Mailbox::fetchFinished = (nbNewMails, callback) ->
        @updateAttributes imapLastFetchedDate: new Date(), (err) =>
            return callback err if err
            LogMessage.createNewMailInfo @, nbNewMails, callback

    # Mark fetch failed error and store a notification about it.
    Mailbox::fetchFailed = (callback) ->
        LogMessage.createCheckMailError @, callback

    # Mark import as failed and stores a notification message about it.
    Mailbox::importError = (callback) ->
        data =
            status: "prepare_failed"
            statusMsg: "import preparation failed"

        @updateAttributes data, (error) =>
            if error
                return callback error if callback?
            else
                LogMessage.createImportPreparationError @, callback

    Mailbox::importStarted = (callback) ->
        data =
            status: "import_preparing"
            statusMsg: "import started"

        @updateAttributes data, (error) =>
            if error
                callback error
            else
                LogMessage.createImportStartedInfo @, callback

    # Mark import as successfull and stores a notification message about it.
    Mailbox::importSuccessfull = (callback) ->
        data =
            status: "imported"
            statusMsg: "import complete"

        @updateAttributes data, (error) =>
            if error
                callback error
            else
                LogMessage.createImportSuccess @, callback


    # Mark import as failed and stores a notification message about it.
    Mailbox::importFailed = (err, callback) ->

        @log err

        data =
            status: "import_failed"
            statusMsg: "import failed"

        @updateAttributes data, (error) =>
            if error
                @log 'cant mark import as failed'
                @log error
                callback err
            else
                LogMessage.createBoxImportError @

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

        @importStarted =>

            @getMailGetter (err, getter) =>
                return @importFailed err, callback if err

                getter.listFolders (err, folders) =>
                    return @importFailed err, callback if err

                    #forEach folder in folders
                    folders = [] unless folders
                    async.eachSeries folders, (folder, cb) =>

                        folder.mailbox = @id

                        Folder.create folder, (err, folder) =>

                            folder.setupImport getter, (err) =>
                                @log err if err
                                cb()

                    , (err) => # when all folders have been processed

                        data =
                            activated: true
                            status: "importing"

                        @updateAttributes data, (err) =>
                            return @importFailed err, callback if err

                            getter.logout callback




    # Run the real import grab all mailtobes from database and fetch message one by
    # one based on this list.
    Mailbox::doImport = (callback = ->) ->

        @log "Start import"
        @getMailGetter (err, getter)  =>
            return callback err if err

            Folder.findByMailbox @id, (err, folders) =>
                return callback err if err

                folders = [] unless folders

                success = 0
                done    = 0
                total   = 0
                oldPercent = 0

                for folder in folders
                    total += folder.mailsToBe?.length or 0

                @log "total mails to import : #{total}"

                async.eachSeries folders, (folder, cb) =>

                    @log "Importing folder #{folder.path}"

                    progressHandler = (curSuccess, curDone, curTotal) =>
                        percent = Math.floor(100 * (done + curDone) / total)
                        if percent isnt oldPercent
                            oldPercent = percent
                            @progress percent

                    folder.doImport getter, progressHandler, (err, doneNb) =>
                        done += doneNb
                        @log err if err
                        cb() #do not pass error to keep looping

                , (err) =>

                    @importSuccessfull (err) =>
                        @log err if err

    #setup then do
    Mailbox::fullImport = (callback) ->
        @setupImport (err) =>
            if err then @log err
            else @doImport callback


    # Get last changes from remote inbox (defined by limit, get the limit latest
    # mails...) and update the current mailbox mails if needed.
    # Changes are based upon flags. If a mail has no flag it is considered as
    # deleted. Else it updates read and starred status if they change.
    # Called when the user hit refresh, so --theirs strategy
    Mailbox::synchronizeChanges = (getter, limit, callback) ->
        getter.getLastFlags limit, (err, flagDict) =>
            return callback err if err
            params =
                startkey: [@id]
                limit: limit
            Mail.fromMailboxByDate params, (err, mails) =>
                return callback err if err
                for mail in mails
                    flags = flagDict[mail.idRemoteMailbox]

                    if flags? then mail.updateFlags flags
                    else           mail.destroy()

                callback()


    Mailbox::syncOneMail = (mail, newflags, callback) ->
        @getMailGetter (err, getter) ->
            return callback err if err

            Folder.find mail.folder, (err, folder) ->
                return callback err if err

                folder.syncOneMail getter, mail, newflags, callback
