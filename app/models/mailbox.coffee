MailSender = require '../../lib/mail_sender'
MailGetter = require '../../lib/mail_getter'


# helpers

Mailbox::log = (msg) ->
    console.info "#{@} #{msg}"

Mailbox::toString = ->
    "[Mailbox #{@name} #{@id}]"


# Destroy helpers

# Delete mailbox and everthing related mails, mailToBes, attachments,
# accounts...
Mailbox::remove = (callback) ->
    @log "destroying box..."
    @destroyMails (err) =>
        @log err if err
        @destroyAttachments (err) =>
            @log err if err
            @destroyMailsToBe (err) =>
                @log err if err
                @destroyAccount (err) =>
                    @log err if err
                    @destroy (err) =>
                        @log err if err
                        @log "destroying finished..."
                        callback()

# Destroy mails linked to current mailbox
Mailbox::destroyMails = (callback) ->
    Mail.requestDestroy "bymailbox", key: @id, callback

# Destroy mail to bes linked to current mailbox
Mailbox::destroyMailsToBe = (callback) ->
    params =
        startkey: [@id]
        endkey: [@id + "0"]
    MailToBe.requestDestroy "bymailbox", params, callback

# Destroy attachments linked to current mailbox
Mailbox::destroyAttachments = (callback) ->
    Attachment.requestDestroy "bymailbox", key: @id, callback

# Mark last fetched date to current mailbox and store a notification about it.
Mailbox::fetchFinished = (callback) ->
    @updateAttributes imapLastFetchedDate: new Date(), (err) =>
        if err
            callback err
        else
            LogMessage.createNewMailInfo @, callback

# Mark fetch failed error and store a notification about it.
Mailbox::fetchFailed = (callback) ->
    data =
        status: "Mail check failed."

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createCheckMailError @, callback

# Mark import as failed and stores a notification message about it.
Mailbox::importError = (callback) ->
    data =
        imported: false
        status: "Could not prepare the import."

    @updateAttributes data, (error) =>
        if error
            callback error if callback?
        else
            LogMessage.createImportPreparationError @, callback

# Mark import as successfull and stores a notification message about it.
Mailbox::importSuccessfull = (callback) ->
    data =
        imported: true
        importing: true
        status: "Import successful !"

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createImportSuccess @, callback


# Mark import as failed and stores a notification message about it.
Mailbox::importFailed = (callback) ->
    data =
        imported: false
        importing: false
        activated: false

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createBoxImportError @

# Update box status with given progress and stores a notification about it.
Mailbox::progress = (progress, callback) ->
    data =
        status: "Import #{progress} %"

    @updateAttributes data, (error) =>
        LogMessage.createImportProgressInfo @, progress, callback


# Mark import as failed and stores a notification message about it.
Mailbox::markError = (error, callback) ->
    data =
        status: error.toString()

    @updateAttributes data, (err) ->
        if err
            callback err
        else
            LogMessage.createImportError error, callback


# Send a mail by using smpt server set in the configuration of the current
# mailbox.
Mailbox::sendMail = (data, callback) ->
    sender = new MailSender @

    @log "Sending mail"
    sender.sendMail data (err) ->
        if err
            @log "Sending mail failed"
            callback err
        else
            @log "Message sent successfully!"
            callback()


# Connect mailbox to remote inbox.
Mailbox::openInbox = (callback) ->
    @mailGetter = new MailGetter @
    @mailGetter.openInbox (err, server) =>
        if err
            @log "INBOX opening failed"
        else
            @log "INBOX opened successfully"
        callback err, server


# Close connection with the remote mailbox.
Mailbox::closeBox = (callback) ->
    @mailGetter.closeBox callback


# Get message corresponding to given remote ID, save it to database and
# download its attachments.
Mailbox::fetchMessage = (mailToBe, callback) ->
    if typeof mailToBe is "string"
        remoteId = mailToBe
    else
        remoteId = mailToBe.remoteId

    @mailGetter.fetchMail remoteId, (err, mail, attachments) =>
        Mail.create mail, (err, mail) =>
            if err
                callback err
            else
                msg = "New mail created: #{mail.idRemoteMailbox}"
                msg += " #{mail.id} [#{mail.subject}] "
                msg += JSON.stringify mail.from
                @log msg

                mail.saveAttachments attachments, (err) ->
                    return callback(err) if err

                    if typeof mailToBe is "string"
                        callback null, mail
                    else
                        mailToBe.destroy (error) ->
                            return callback(err) if err
                            callback null, mail

# Get last changes from remote inbox (defined by limit, get the limit latest
# mails...) and update the current mailbox mails if needed.
# Changes are based upon flags. If a mail has no flag it is considered as
# deleted. Else it updates read and starred status if they change.
Mailbox::synchronizeChanges = (limit, callback) ->
    @mailGetter.getLastFlags (err, flagDict) =>
        return callback err if err
        params =
            startkey: [@id]
            limit: limit
        Mail.fromMailboxByDate params, (err, mails) =>
            return callback err if err
            for mail in mails
                flags = flagDict[mail.idRemoteMailbox]
                if flags?
                    mail.updateFlags flags
                else
                    mail.destroy()
            callback()

# Check if new mails arrives in remote inbox (base this on the last email
# fetched id). Then it synchronize last recieved mails.
Mailbox::getNewMails = (limit, callback) ->

    id = Number(@imapLastFetchedId) + 1
    range = "#{id}:#{id + limit}"
    @log "Fetching new mails: #{range}"

    @openInbox (err) =>
        @loadNewMails id, range,  (err) =>
            if err
                @closeBox =>
                    @fetchFailed callback
            else
                @log "New Mails fetched"
                @synchronizeChanges 100,  =>
                    @closeBox =>
                        @fetchFinished callback

# Load given range of mails inside inbox considering that box is already open.
Mailbox::loadNewMails = (id, range, callback) ->
    @mailGetter.getMails range, (err, results) =>
        if err
            @log "Can't retrieve new mails"
            console.log err
            callback err
        else if results.length is 0
            @log "Nothing to download"
            callback()
        else
            @log "#{results.length} mails to download"
            fetchNewMails 0, results, 0

    # Fetch new mail sequentially via a recursive function.
    # Run callback when the fetching finished.
    fetchNewMails = (i, results, mailsDone) =>
        @log "fetch new mail: #{i}/#{results.length}"

        if i < results.length
            remoteId = results[i]

            @fetchMessage remoteId, (err, mail) =>

                if err
                    @log "Mail #{remoteId} cannot be imported"
                    fetchNewMails i + 1, results, mailsDone
                else
                    data = imapLastFetchedId: mail.idRemoteMailbox
                    @updateAttributes data, (err) ->
                        if err
                            @log "can't update mailbox state"
                            console.log err
                            callback err
                        else
                            mailsDone++
                            fetchNewMails (i + 1), results, mailsDone

        else
            if mailsDone isnt results.length
                @log "Could not import all the mail. Retry"
                callback new Error "Not full fetching"
            else
                callback()


# Prepare import of current mailbox. Grab and store all ids that should be
# retrieved. This is useful in case of crash if the import should be start
# again.
Mailbox::setupImport = (callback) ->

    # no need to initialize import again if it was importing.
    return callback() if @importing

    LogMessage.createImportStartedInfo @, =>
        @openInbox (err) =>
            if err
                LogMessage.createImportPreparationError @, =>
                    callback err
            else
                @mailGetter.getAllMails (err, results) =>
                    if err
                        @log "Can't retrieve emails"
                        console.log err
                        callback err
                    else
                        @log "Search query succeeded"

                        unless results.length
                            @log "No message to fetch"
                            @closeBox callback
                        else
                            @log "#{results.length} mails to download"
                            @log "Start grabing mail ids"
                            fetchMailIds results, 0, 0, results.length, 0


    # Store all remote mail IDs via a recursive function.
    # Run callback when it finishes.
    fetchMailIds = (results, i, mailsDone, mailsToGo, maxId) =>

        if i < results.length
            id = results[i]
            idInt = parseInt id
            maxId = idInt if idInt > maxId

            @mailsToBe.create remoteId: idInt, (error, mailToBe) =>
                if error
                    @closeBox =>
                        @log "Error occured while saving email."
                        callback()
                else
                    mailsDone++

                    if mailsDone is mailsToGo
                        @log "Finished saving ids to database"
                        @log "max id = #{maxId}"
                        data =
                            mailsToImport: results.length
                            imapLastFetchedId: maxId
                            activated: true
                            importing: true

                        @updateAttributes data, (err) =>
                            if err
                                @log "can't save mailbox state"
                            else
                                @log "All mail ids collected"
                                callback()
                    else
                        fetchMailIds results, i + 1, mailsDone, mailsToGo, maxId

        else
            if mailsDone isnt mailsToGo
                @closeBox =>
                    @log  "Error occured - not all ids could be stored to the database"
                    callback()

# Run the real import grab all mailtobes from database and fetch message one by
# one based on this list.
Mailbox::doImport = (callback) ->
    importMails = =>
        MailToBe.fromMailbox @, (err, mailsToBe) =>
            if err
                console.log err
                @closeBox =>
                    @importFailed callback

            else if mailsToBe.length is 0
                @log "Import: Nothing to download"
                @closeBox =>
                    @importSuccessfull callback

            else
                fetchMails mailsToBe, 0, mailsToBe.length, 0

    finishImport = =>
        @importSuccessfull (err) =>
            @log err if err
            @destroyMailsToBe (err) =>
                @log err if err
                callback() if callback?

    # Recursive function to fetch all mails.
    # Update progress status during the import (create a notification).
    # Make import as failed if one message is not imported.
    fetchMails = (mailsToBe, i, mailsToGo, mailsDone) =>
        @log "Import progress:  #{i}/#{mailsToBe.length}"

        if i < mailsToBe.length
            mailToBe = mailsToBe[i]

            @fetchMessage mailToBe, (err) =>
                if err
                    @log 'Mail creation error, skip this mail'
                    console.log err
                    fetchMails mailsToBe, i + 1, mailsToGo, mailsDone
                else
                    previousProgress = (mailsDone / mailsToGo) * 100
                    previousStep = Math.floor(previousProgress / 10)
                    mailsDone++
                    progress = (mailsDone / mailsToGo) * 100
                    step = Math.floor(progress / 10)


                    if step isnt previousStep and mailsToGo isnt mailsDone
                        @progress step * 10, (err) ->
                            console.error err if err

                    if mailsToGo is mailsDone
                        @importSuccessfull (err) ->
                            finishImport()
                    else
                        fetchMails mailsToBe, i + 1, mailsToGo, mailsDone
        else
            @closeBox =>
                if mailsToGo isnt mailsDone
                    @log "The box was not fully imported."
                finishImport()

    @log "Start import"
    if @mailGetter?
        importMails()
    else
        @openInbox (err)  =>
            importMails()

# Mark given mail as read. This is needed when the user read a message on his
# Cozy, to synchronize the remote mailbox.
Mailbox::markMailAsRead = (mail, callback) ->
    @log "Add read flag to mail #{mail.idRemoteMailbox}"
    @openInbox (err) =>
        if err
            console.log err
            @closeBox ->
                callback err
        else
            @mailGetter.markRead mail, (err) =>
                if err
                    console.log err
                    @log "mail #{mail.idRemoteMailbox} not marked as seen"
                else
                    @log "mail #{mail.idRemoteMailbox} marked as seen"
                @closeBox callback
