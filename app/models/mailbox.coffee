###
    @file: mailbox.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The model used to wrap tasks on other servers:
            * fetching mails with node-imap,
            * parsing mail with nodeparser,
            * saving mail to the database,
            * sending mail with nodemailer,
            * flagging mail on remote servers (not yet implemented)
###

MailSender = require '../../lib/mail_sender'
MailGetter = require '../../lib/mail_getter'


# helpers

Mailbox::log = (msg) ->
    console.info "#{@} #{msg}"

Mailbox::toString = ->
    "[Mailbox #{@name} #{@id}]"


# Destroy helpers

Mailbox::destroyMails = (callback) ->
    Mail.requestDestroy "bymailbox", key: @id, callback

Mailbox::destroyMailsToBe = (callback) ->
    params =
        startkey: [@id]
        endkey: [@id + "0"]
    MailToBe.requestDestroy "bymailbox", params, callback

Mailbox::destroyAttachments = (callback) ->
    Attachment.requestDestroy "bymailbox", key: @id, callback

Mailbox::fetchFinished = (callback) ->
    @updateAttributes imapLastFetchedDate: new Date(), (error) =>
        if error
            callback error
        else
            LogMessage.createNewMailInfo @, callback
            
Mailbox::fetchFailed = (callback) ->
    data =
        status: "Mail check failed."

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createCheckMailError @, callback

Mailbox::importError = (callback) ->
    data =
        imported: false
        status: "Could not prepare the import."

    @updateAttributes data, (error) =>
        if error
            callback error if callback?
        else
            LogMessage.createImportPreparationError @, callback

Mailbox::importSuccessfull = (callback) ->
    data =
        imported: true
        status: "Import successful !"

    @updateAttributes data, (error) =>
        if error
            callback error
        else
            LogMessage.createImportSuccess @, callback

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

Mailbox::progress = (progress, callback) ->
    data =
        status: "Import #{progress} %"

    @updateAttributes data, (error) =>
        LogMessage.createImportProgressInfo @, progress, callback


Mailbox::markError = (error, callback) ->
    data =
        status: error.toString()

    @updateAttributes data, (err) ->
        if err
            callback err
        else
            LogMessage.createImportError error, callback
    

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

Mailbox::openInbox = (callback) ->
    @mailGetter = new MailGetter @
    @mailGetter.openInbox (err, server) =>
        if err
            @log "INBOX opening failed"
        else
            @log "INBOX opened successfully"
        callback err, server
                
Mailbox::closeBox = (server, callback) ->
    @mailGetter.closeBox callback

Mailbox::fetchMessage = (mailToBe, callback) ->
    if typeof mailToBe is "string"
        remoteId = mailToBe
    else
        remoteId = mailToBe.remoteId

    @mailGetter.fetchMail remoteId, (err, mail) =>
        Mail.create mail, (err, mail, attachments) =>
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

     
Mailbox::synchronizeChanges = (callback) ->
    @mailGetter.getFlags (err, flagDict) =>
        Mail.fromMailbox key: @id, (err, mails) =>
            return callback err if err
            for mail in mails
                flags = flagDict[mail.idRemoteMailbox]
                if flags?
                    mail.updateFlags flags
                else
                    mail.destroy()
            callback()

Mailbox::getNewMail = (limit, callback) ->
    
    id = Number(@imapLastFetchedId) + 1
    range = "#{id}:#{id + limit}"
    @log "Fetching mail #{@} | UID #{range})"
                            
    @openInbox (err) =>
        @loadNewMails id, range,  =>
            @log "New Mails fetched"
            @synchronizeChanges  =>
                @closeBox callback
            
Mailbox::loadNewMails = (id, range, callback) ->
    @mailGetter.getMails range, (err, results) =>
        if err
            @log "Can't retrieve new mails"
            console.log err
        else if results.length is 0
            @log "Nothing to download"
            callback err
        else
            @log "#{results.length} mails to download"
            LogMessage.createImportInfo results, @, ->
                fetchNewMails 0, results, callback

    fetchNewMails = (i, results, mailsDone) =>
        @log "fetch new mail: #{i}/#{results.length}"

        if i < results.length
            remoteId = results[i]

            @fetchMessage remoteId, (err, mail) =>
                if err
                    @log "Mail #{remoteId} cannot be imported"
                    fetchNewMails i + 1, results, mailsDone
                else
                    if @imapLastFetchedId < mail.idRemoteMailbox
                        data = imapLastFetchedId: mail.idRemoteMailbox
                        @updateAttributes data, (err) ->
                            if err
                                @log "can't update mailbox state"
                                console.log err
                            else
                                mailsDone++

                                if i is results.length
                                    localCallback()
                                else
                                    fetchNewMails i + 1, results, mailsDone
                    else
                        callback()

        else
            if mailsDone isnt results.length
                @log "Could not import all the mail. Retry"
            localCallback()


###
    ## Specialised function to prepare a new mailbox for import and fetching new mail
###

Mailbox::setupImport = (callback) ->
    
    # global vars
    mailbox = @
 
    @openInbox (err) =>
        if err
            LogMessage.createImportPreparationError mailbox, =>
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

            
    # for every ID, fetch the message
    fetchMailIds = (results, i, mailsDone, mailsToGo, maxId) =>

        if i < results.length
            id = results[i]
            idInt = parseInt id
            maxId = idInt if idInt > maxId
    
            mailbox.mailsToBe.create remoteId: idInt, (error, mailToBe) =>
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
    

Mailbox::doImport = (callback) ->
    importMails = =>
        MailToBe.fromMailbox @, (err, mailsToBe) =>
            if err
                console.log err
                @closeBox callback
                
            else if mailsToBe.length is 0
                @log "Import: Nothing to download"
                @closeBox callback
            else
                fetchMails mailsToBe, 0, mailsToBe.length, 0
                    
    fetchMails = (mailsToBe, i, mailsToGo, mailsDone) =>
        @log "Import progress:  #{i}/#{mailsToBe.length}"
        
        if i < mailsToBe.length
            mailToBe = mailsToBe[i]

            @fetchMessage mailToBe, (err) =>
                if err
                    @log 'Mail creation error, skip this message'
                    console.log err
                    fetchMails mailsToBe, i + 1, mailsToGo, mailsDone
                else
                    mailsDone++
                    
                    if mailsToGo is mailsDone
                        callback()
                    else
                        fetchMails mailsToBe, i + 1, mailsToGo, mailsDone
                                       
        else
            @closeBox =>
                if mailsToGo isnt mailsDone
                    @log "The box was not fully imported."
                callback()

    @log "Start import"
    if @mailGetter?
        importMails()
    else
        @openInbox (err)  =>
            importMails()


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
