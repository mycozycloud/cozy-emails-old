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
                @mailbox.log "Connection established successfully"
                callback err, @server
        else
            @mailbox.log 'No host defined'
            callback new Error 'No host defined'
             
    openInbox: (callback) =>
        @connect (err, server) =>
            if err
                # error is not directly returned because in case of wrong
                # credentials it displays password in logs.
                @mailbox.log "[Error] #{err.message}"
                callback new Error("Connection failed")
            else
                @server.openBox 'INBOX', false, (err, box) =>
                    @mailbox.log "INBOX opened successfully"
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
        fetch = @server.fetch remoteId,
            request:
                body: 'full'
                headers: false

        messageFlags = []
        fetch.on 'message', (message) =>
            parser = new mailparser.MailParser()

            parser.on "end", (mailParsedObject) =>
                dateSent = @getDateSent mailParsedObject
                attachments = mailParsedObject.attachments
                mail =
                    mailbox: @mailbox.id
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
                    idRemoteMailbox: remoteId
                    headersRaw: JSON.stringify mailParsedObject.headers
                    references: mailParsedObject.references or ""
                    inReplyTo: mailParsedObject.inReplyTo or ""
                    flags: JSON.stringify messageFlags
                    read: "\\Seen" in messageFlags
                    flagged: "\\Flagged" in messageFlags
                    hasAttachments: if mailParsedObject.attachments then true else false

                callback null, mail, attachments

            message.on "data", (data) ->
                # on data, we feed the parser
                parser.write data.toString()

            message.on "end", ->
                # additional data to store, which is "forgotten" byt the parser
                # well, for now, we will store it on the parser itself
                messageFlags = message.flags
                do parser.end

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

    getFlags: (callback) ->
        @mailbox.log "fetch last modification started."
        @mailbox.log "1:#{@mailbox.imapLastFetchedId}"
        fetch = @server.fetch "1:#{@mailbox.imapLastFetchedId}"
        flagDict = {}
        fetch.on 'message', (msg) =>
            msg.on 'end', =>
                flagDict[msg.seqno] = msg.flags

        fetch.on 'end', (msg) =>
            @mailbox.log "fetch modification finished."
            callback null, flagDict

    markRead: (mail, callback) ->
        server.addFlags mail.idRemoteMailbox, 'Seen', callback

module.exports = MailGetter
