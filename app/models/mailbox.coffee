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

nodemailer = require "nodemailer"
imap = require "imap"
mailparser = require "mailparser"


# helpers

getDateSent = (mailParsedObject) ->
    # choose the right date
    if mailParsedObject.headers.date
        if mailParsedObject.headers.date instanceof Array
            # if an array pick the first date
            dateSent = new Date mailParsedObject.headers.date[0]
        else
            # else take the whole thing
            dateSent = new Date mailParsedObject.headers.date
    else
        dateSent = new Date()


# Destroy helpers

Mailbox::destroyMails = (callback) ->
    Mail.requestDestroy "mailbox", key: @id, callback

# Just to be able to recognise the mailbox in the console
Mailbox::toString = ->
    "[Mailbox " + @name + " #" + @id + "]"

Mailbox::fetchFinished = (callback) ->
    @updateAttributes IMAP_last_fetched_date: new Date(), (error) =>
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
            callback error
        else
            LogMessage.createImportPreparationError @, callaback

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
    
###
    Generic function to send mails, using nodemailer
###
Mailbox::sendMail = (data, callback) ->
    
    # create the connection - transport object, 
    # and configure it with our mialbox's data
    transport = nodemailer.createTransport "SMTP",
        host: @SMTP_server
        secureConnection: @SMTP_ssl
        port: @SMTP_port
        auth:
            user: @login
            pass: @pass

    # configure the message object to send
    message =
        from: @SMTP_send_as
        to: data.to
        cc: data.cc if data.cc?
        bcc: data.bcc if data.bcc?
        subject: data.subject
        headers: data.headers if data.headers?
        html: data.html
        generateTextFromHTML: true
        
    console.log "Sending Mail"
    transport.sendMail message, (error) ->
        if error
            console.error "Error occured"
            console.error error.message
            callback error
        else
            console.log "Message sent successfully!"
            callback()

    transport.close()


###
    ## Fetching new mail from server
    
    # @job - kue job
    # @callback - success callback
    # @limit - how many new messages we want to download at max

###

Mailbox::connectImapServer = (callback) ->

    # let's create a connection
    server = new imap.ImapConnection
        username: @login
        password: @pass
        host: @IMAP_server
        port: @IMAP_port
        secure: @IMAP_secure

    # set up lsiteners, handle errors and callback
    server.on "alert", (alert) ->
        console.log "[SERVER ALERT] #{alert}"

    server.on "error", (error) =>
        console.error "[ERROR]: #{error.toString()}"
        @updateAttributes status: error.toString(), (err) ->
            callback error

    server.on "close", (error) ->
        if error
            console.log "Connection closed (error: #{error.toString()})"
        else
            console.log "Server connectiion Connection closed."
     
    server.connect (err) =>
        callback err, server
             
Mailbox::loadInbox = (server, callback) ->
    console.log "[#{@name}] Connection established successfuly"
    server.openBox 'INBOX', false, (err, box) =>
        console.log "[#{@name}] INBOX opened successfuly"
        callback err, server
 
Mailbox::fetchMessage = (server, mailToBe, callback) ->
    
    if typeof mailToBe is "string"
        remoteId = mailToBe
    else
        remoteId = mailToBe.remoteId

    fetch = server.fetch remoteId,
        request:
            body: 'full'
            headers: false

    messageFlags = []
    fetch.on 'message', (message) =>
 
        parser = new mailparser.MailParser()

        parser.on "end", (mailParsedObject) =>
            dateSent = getDateSent mailParsedObject
            attachments = mailParsedObject.attachments
            mail =
                mailbox: @id
                date: dateSent.toJSON()
                dateValueOf: dateSent.valueOf()
                createdAt: new Date().valueOf()
                from: JSON.stringify mailParsedObject.from
                to: JSON.stringify mailParsedObject.to
                cc: JSON.stringify mailParsedObject.cc
                subject: mailParsedObject.subject
                priority: mailParsedObject.priority
                text: mailParsedObject.text
                html: mailParsedObject.html
                id_remote_mailbox: remoteId
                headers_raw: JSON.stringify mailParsedObject.headers
                references: mailParsedObject.references or ""
                inReplyTo: mailParsedObject.inReplyTo or ""
                flags: JSON.stringify messageFlags
                read: "\\Seen" in messageFlags
                flagged: "\\Flagged" in messageFlags
                hasAttachments: if mailParsedObject.attachments then true else false

            Mail.create mail, (err, mail) ->
                if err
                    callback err
                else
                    msg = "New mail created: #{mail.id_remote_mailbox}"
                    msg += " #{mail.id} [#{mail.subject}] "
                    msg += JSON.stringify mail.from
                    console.log msg
                    
                    mail.saveAttachments attachments, (err) ->
                        return callback(err) if err

                        if typeof mailToBe is "string"
                            callback mail
                        else
                            mailToBe.destroy (error) ->
                                return callback(err) if err
                                callback mail

        message.on "data", (data) ->
            # on data, we feed the parser
            parser.write data.toString()

        message.on "end", ->
            # additional data to store, which is "forgotten" byt the parser
            # well, for now, we will store it on the parser itself
            messageFlags = message.flags
            do parser.end
     

Mailbox::getNewMail = (job, callback, limit=250) ->
    
    # global vars
    debug = true
    
    # reload
    id = Number(@IMAP_last_fetched_id) + 1
    console.log "Fetching mail #{@} | UID #{id}:#{id + limit})"

    @connectImapServer (err, server) =>
        return emitOnErr(server, err) if err
        @loadInbox server, (err) =>
            return emitOnErr server, err if err
            loadNewMails(server, id)
                            
    emitOnErr = (server, error) ->
        if error
            console.log error
            server.emit "error", error if server?

    loadNewMails = (server, id) =>
        range = "#{id}:#{id + limit}"
        server.search [['UID', range]], (err, results) =>
            return emitOnErr(server, err) if err

            unless results.length
                console.log "Nothing to download"
                server.logout ->
                    callback()
            else
                console.log "#{results.length} mails to download"
                LogMessage.createImportInfo results, @, ->
                    fetchOne server, 0, results

    fetchOne = (server, i, results, mailsDone) =>
        console.log "#{@} fetch new mail: #{i}/#{results.length}"
        mailsDone = 0

        if i < results.length
            remoteId = results[i]

            @fetchMessage server, remoteId, (err, mail) =>
                if err
                    emitOnErr server, err
                else
                    if @IMAP_last_fetched_id < mail.id_remote_mailbox
                        data = IMAP_last_fetched_id: mail.id_remote_mailbox
                        @updateAttributes data, (err) ->
                            if err
                                emitOnErr server, err
                            else
                                mailsDone++
                                job.progress mailsDone, results.length

                                if mailsToGo is mailsDone
                                    callback()
                                else
                                    fetchOne(server, i + 1, results, mailsDone)

        else
            server.logout ->
                if mailsToGo isnt mailsDone
                    msg = "Could not import all the mail. Retry"
                    server.emit "error", new Error(msg)


###
    ## Specialised function to prepare a new mailbox for import and fetching new mail
###

Mailbox::setupImport = (callback) ->
    
    # global vars
    mailbox = @
 
    @connectImapServer (err, server) =>
        if err
            emitOnErr server, err
        else
            @loadInbox server, (err) ->
                if err
                    emitOnErr server, err
                else
                    loadInboxMails server
              
    emitOnErr = (server, error) ->
        if error
            console.log error
            server.emit "error", error if server?

    loadInboxMails = (server) ->
        server.search ['ALL'], (err, results) =>
            if err
                emitOnErr server, err
            else
                console.log "Search query succeeded"

                unless results.length
                    console.log "No message to fetch"
                    server.logout()
                    callback()
                else
                    console.log "[" + results.length + "] mails to download"
                    fetchOne server, results, 0, 0, results.length, 0

            
    # for every ID, fetch the message
    fetchOne = (server, results, i, mailsDone, mailsToGo, maxId) =>
        
        if i < results.length
            
            id = results[i]
        
            # find the biggest ID
            idInt = parseInt id
            maxId = idInt if idInt > maxId
    
            mailbox.mailsToBe.create remoteId: idInt, (error, mailToBe) =>
                if error
                    server.logout -> server.emit "error", error
                else
                    console.log "#{mailToBe.remoteId} id saved successfully"
                    mailsDone++
        
                    if mailsDone is mailsToGo
                        console.log "Finished saving ids to database"
                        console.log "max id = #{maxId}"
                        data =
                            mailsToImport: results.length
                            IMAP_last_fetched_id: maxId
                            activated: true
                            importing: true

                        @updateAttributes data, (err) ->
                            server.logout () ->
                                callback err
                    else
                        fetchOne server, results, i + 1, mailsDone, mailsToGo, maxId
        else
            # synchronise - all ids saved to the db
            if mailsDone isnt mailsToGo
                server.logout ->
                    msg =  "Error occured - not all ids could be stored to the database"
                    server.emit "error", new Error msg
    

###
    ## Specialised function to get as much mails as possible from ids stored 
    # previously in the database
###

Mailbox::doImport = (job, callback) ->

    emitOnErr = (server, error) ->
        if error
            server.logout () ->
                console.log error
                server.emit "error", error if server?
  
    @connectImapServer (err, server) =>
        return emitOnErr server, err if err
        MailToBe.fromMailbox @, (err, mailsToBe) =>
            if err
                emitOnErr server, err
            else if not mailsToBe.length
                console.log "Import #{@name}: Nothing to download"
                server.logout()
                callback()
            else
                @loadInbox server, =>
                    fetchOne server, mailsToBe, 0, mailsToBe.length, 0
                    
    fetchOne = (server, mailsToBe, i, mailsToGo, mailsDone) =>
        console.log "Import #{@name} progress:  #{i}/#{mailsToBe.length}"
        
        if i < mailsToBe.length
            mailToBe = mailsToBe[i]

            @fetchMessage server, mailToBe, (err) =>
                if err
                    console.log 'Mail creation error, skip this message'
                    console.log err
                    fetchOne server, mailsToBe, i + 1, mailsToGo, mailsDone
                else
                    mailsDone++
                    diff = mailsToGo - mailsDone
                    importProgress = @mailsToImport - diff
                    job.progress importProgress, @mailsToImport
                    
                    if mailsToGo is mailsDone
                        callback()
                    else
                        fetchOne server, mailsToBe, i + 1, mailsToGo, mailsDone
                                       
        else
            server.logout =>
                if mailsToGo isnt mailsDone
                    msg = "Import #{@name}: the box was not fully impoterd."
                    server.emit 'error', new Error msg
                callback()
