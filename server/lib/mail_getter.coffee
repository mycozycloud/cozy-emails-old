ImapConnection = require "imap"
{MailParser} = require "mailparser"

# Utility class to get mails.
class MailGetter

    SPECIALUSEFOLDERS = ['INBOX', 'SENT', 'TRASH', 'DRAFTS',
        'IMPORTANT', 'SPAM', 'STARRED', 'ALLMAIL', 'ALL']

    constructor: (@mailbox, @password) ->

    # Start connection with the server describe in the mailbox configuration.
    connect: (callback) ->
        @server = new ImapConnection
            user: @mailbox.login
            password: @password
            host:     @mailbox.imapServer
            port:     @mailbox.imapPort
            secure:   @mailbox.imapSecure

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
        @server.connect (err) =>
            console.log err
            @mailbox.log 'ready!'

            if @mailbox.imapServer?
                if err
                    @mailbox.log "Connection failed"
                    callback err
                else
                    @mailbox.log "Connection established successfully"
                    callback null
            else
                @mailbox.log 'No host defined'
                callback new Error 'No host defined'

    listFolders: (callback) =>
        @server.getBoxes (err, boxes) =>

            folders = []
            @flattenBoxesIntoFolders '', boxes, folders

            callback null, folders

    flattenBoxesIntoFolders: (parentpath, obj, folders) ->

        for key, value of obj
            path = parentpath + key

            unless 'NOSELECT' in value.attribs

                type = null

                for specialType in SPECIALUSEFOLDERS
                    if specialType in value.attribs
                        type = specialType

                folders.push
                    name: key
                    path: path
                    specialType: type
                    attribs: value.attribs

            if value.children
                childpath = path + value.delimiter
                @flattenBoxesIntoFolders childpath, value.children, folders


    # Start a connexion with remote IMAP server and open INBOX.
    openBox: (folder, callback) =>
        @server.openBox folder, false, (err, box) =>
            callback err, @server

    # Close INBOX
    closeBox: (callback) =>
        @mailbox.log "closing box"
        @server.closeBox callback

    logout: (callback) =>
        @mailbox.log "logging out"
        @server.logout callback
        # (err) =>
        #     if err
        #         @mailbox.log "cant close box"
        #         callback err if callback?
        #     else
        #        @server.logout =>
        #             @mailbox.log "logged out from IMAP server"
        #             callback() if callback?

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
                    parser = new MailParser()

                    parser.on "end", (mailParsed) =>
                        dateSent = @getDateSent mailParsed
                        attachments    = mailParsed.attachments
                        hasAttachments = not not attachments

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
                            idRemoteMailbox: new String(remoteId)
                            remoteUID: remoteId
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
    getLastFlags: (folder, limit, callback) ->
        start = folder.imapLastFetchedId - limit
        start = 1 if start < 1
        return callback null, {} if start > folder.imapLastFetchedId
        @getFlags "#{start}:#{folder.imapLastFetchedId}", callback

    # Get all the mailbox flags
    getAllFlags: (callback) ->
        @getFlags "1:#{@folder.imapLastFetchedId}", callback

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


    setFlags: (mail, newflags, callback) ->
        @getFlags mail.remoteUID, (err, dict) =>
            return callback err if err
            console.log dict
            oldflags = dict[mail.remoteUID]

            console.log newflags, oldflags

            toAdd = []
            toDel = []

            for flag in oldflags
                unless flag in newflags
                    toDel.push flag

            for flag in newflags
                unless flag in oldflags
                    toAdd.push flag

            console.log toAdd, toDel

            @delFlags mail.idRemoteMailbox, toDel, (err) =>
                return callback err if err
                @addFlags mail.idRemoteMailbox, toAdd, callback

    delFlags: (uid, flags, callback) ->
        return callback null if flags.length is 0
        @server.delFlags uid, flags, callback

    addFlags: (uid, flags, callback) ->
        return callback null if flags.length is 0
        @server.addFlags uid, flags, callback

module.exports = MailGetter
