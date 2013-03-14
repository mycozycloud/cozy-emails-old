imap = require "imap"
mailparser = require "mailparser"

# Utility class to get mails.
class MailGetter

    constructor: (@mailbox) ->

    # Start connection with the server describe in the mailbox configuration.
    connect: (callback) ->
        @server = new imap.ImapConnection
            username: @mailbox.login
            password: @mailbox.password
            host: @mailbox.imapServer
            port: @mailbox.imapPort
            secure: @mailbox.imapSecure

        @server.on "alert", (alert) =>
            @mailbox.log "[SERVER ALERT] #{alert}"

        @server.on "error", (err) =>
            @mailbox.log "[ERROR]: #{err.toString()}"
            @mailbox.updateAttributes status: err.toString(), ->
                LogMessage.createBoxImportError ->
                    callback err

        @server.on "close", (err) =>
            if err
                @mailbox.log "Connection closed (error: #{err.toString()})"
            else
                @mailbox.log "Server connection closed."
         
        @mailbox.log "Try to connect..."
        if @mailbox.imapServer?
            @server.connect (err) =>
                if err
                    @mailbox.log "Connection failed"
                    callback err
                else
                    @mailbox.log "Connection established successfully"
                    callback null
        else
            @mailbox.log 'No host defined'
            callback new Error 'No host defined'
             
    # Start a connexion with remote IMAP server and open INBOX.
    openInbox: (callback) =>
        @connect (err) =>
            if err
                # error is not directly returned because in case of wrong
                # credentials it displays password in logs.
                @mailbox.log "[Error] #{err.message}"
                callback new Error("Connection failed")
            else
                @server.openBox 'INBOX', false, (err, box) =>
                    callback err, @server

    # Close INBOX and stop server connection.
    closeBox: (callback) =>
        @server.closeBox (err) =>
            if err
                @mailbox.log "cant close box"
                callback err if callback?
            else
               @server.logout =>
                    @mailbox.log "logged out from IMAP server"
                    callback() if callback?

    # Retrieve all mails.
    getAllMails: (callback) =>
        @server.search ['ALL'], callback

    # Retrieve all with ID in a given range.
    getMails: (range, callback) =>
        @server.search [['UID', range]], callback
    # Fetch mail with given remoteID and make a new
    # mail object from it. Download its attachments and return them separately.
    fetchMail: (remoteId, callback) =>
        mail = null
        fetch = @server.fetch remoteId,
            body: true
            headers:
                parse: false
            cb: (fetch) =>
                messageFlags = []
                fetch.on 'message', (message) =>
                    parser = new mailparser.MailParser()

                    parser.on "end", (mailParsed) =>
                        dateSent = @getDateSent mailParsed
                        attachments = mailParsed.attachments
                        hasAttachments = if attachments then true else false

                        mail =
                            mailbox: @mailbox.id
                            date: dateSent.toJSON()
                            dateValueOf: dateSent.valueOf()
                            createdAt: new Date().valueOf()
                            from: JSON.stringify mailParsed.from
                            to: JSON.stringify mailParsed.to
                            cc: JSON.stringify mailParsed.cc
                            subject: mailParsed.subject
                            priority: mailParsed.priority
                            text: mailParsed.text
                            html: mailParsed.html
                            idRemoteMailbox: remoteId
                            headersRaw: JSON.stringify mailParsed.headers
                            references: mailParsed.references or ""
                            inReplyTo: mailParsed.inReplyTo or ""
                            flags: JSON.stringify messageFlags
                            read: "\\Seen" in messageFlags
                            flagged: "\\Flagged" in messageFlags
                            hasAttachments: hasAttachments
                        callback null, mail, attachments

                    message.on "data", (data) ->
                        # on data, we feed the parser
                        parser.write data.toString()

                    message.on "end", ->
                        # additional data to store, which is "forgotten" byt the parser
                        # well, for now, we will store it on the parser itself
                        messageFlags = message.flags
                        parser.end()

    # Convert date set recieved message into an usual date.
    getDateSent: (mailParsedObject) ->
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

    # Get last 100 mails flags.
    getLastFlags: (callback) ->
        start = @mailbox.imapLastFetchedId - 100
        start = 1 if start < 1
        @getFlags "#{start}:#{@mailbox.imapLastFetchedId}", callback

    # Get all the mailbox flags
    getAllFlags: (callback) ->
        @getFlags "1:#{@mailbox.imapLastFetchedId}", callback

    # Get flags for a given range of IDs.
    getFlags: (range, callback) ->
        flagDict = {}
        @mailbox.log "fetch last modification started."
        @mailbox.log range
        @server.fetch(range,
            cb: (fetch) ->
                fetch.on 'message', (msg) ->
                    msg.on 'end', ->
                        flagDict[msg.uid] = msg.flags
        , (err) =>
            @mailbox.log "fetch modification finished."
            
            
            callback err, flagDict
        )

    # Mark given mail as read by adding remotely the Seen flag to its flags.
    markRead: (mail, callback) ->
        @server.addFlags mail.idRemoteMailbox, 'Seen', callback

module.exports = MailGetter
