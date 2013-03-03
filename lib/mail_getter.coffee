imap = require "imap"
mailparser = require "mailparser"

class MailGetter

    constructor: (@mailbox) ->

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

    closeBox: (callback) =>
        @server.closeBox (err) =>
            if err
                @mailbox.log "cant close box"
                callback err if callback?
            else
               @server.logout =>
                    @mailbox.log "logged out from IMAP server"
                    callback() if callback?

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
                        callback null, mail

                    message.on "data", (data) ->
                        # on data, we feed the parser
                        parser.write data.toString()

                    message.on "end", ->
                        # additional data to store, which is "forgotten" byt the parser
                        # well, for now, we will store it on the parser itself
                        messageFlags = message.flags
                        parser.end()

    getAllMails: (callback) =>
        @server.search ['ALL'], callback

    getMails: (range, callback) =>
        @server.search [['UID', range]], callback

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

    getLastFlags: (callback) ->
        start = @mailbox.imapLastFetchedId - 100
        start = 1 if start < 1
        @getFlags "#{start}:#{@mailbox.imapLastFetchedId}", callback

    getAllFlags: (callback) ->
        @getFlags "1:#{@mailbox.imapLastFetchedId}", callback

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

    markRead: (mail, callback) ->
        @server.addFlags mail.idRemoteMailbox, 'Seen', callback

module.exports = MailGetter
