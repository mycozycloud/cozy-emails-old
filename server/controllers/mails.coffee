async = require('async')
Mail = require '../models/mail'

module.exports =

    getMail: (req, res, next, id) ->
        Mail.find id, (err, mail) =>
            if err then next err
            else if not mail?
                send error: "mail not found", 404
            else
                req.mail = mail
                next()

    show: (req, res, next) ->
        send req.mail

    update: (req, res, next) ->
        markRead = false
        body = req.body
        flagsChanged = req.mail.changedFlags body.flags
        newflags = body.flags

        # flags will be updated after the sync on IMAP succeeds
        delete body.flags

        req.mail.updateAttributes body, (err) =>
            if err then next err
                return send success: true, 200 unless flagsChanged

                Mailbox.find req.mail.mailbox, (err, mailbox) =>
                    return next err if err

                    mailbox.syncOneMail req.mail, newflags, (err) =>
                        return next err if err
                        send success: true, 200

    destroy: (req, res, next) ->
        Mailbox.find req.mail.mailbox, (err, mailbox) =>
            return next err if err

            mailbox.syncOneMail req.mail, ["\\Deleted"], (err) =>
                return next err if err

                req.mail.destroy (err) =>
                    return next err if err

                    send 204


    # send num mails from folder id: folderId
    # starting after timestamp
    # descending order by date
    byFolder: (req, res, next) ->
        num = parseInt req.params.num
        if req.params.timestamp and req.params.timestamp isnt 'undefined'
            timestamp = parseInt req.params.timestamp
        else timestamp = {}

        # TODO use timestamp
        query =
            startkey: [req.params.folderId, timestamp]
            endkey: [req.params.folderId]
            limit: num
            skip: if timestamp then 1 else 0
            descending: true

        Mail.fromFolderByDate query, (err, mails) ->
            if err then next err
            else
                send mails

    # send num mails from the rainbow (merged INBOX folders)
    # starting after timestamp
    # descending order by date
    rainbow: (err, req, res) ->
        limit = parseInt req.params.limit
        if req.params.timestamp and req.params.timestamp isnt 'undefined'
            timestamp = parseInt req.params.timestamp
        else timestamp = {}

        # get inboxes
        MailFolder.byType 'INBOX', (err, inboxes) ->
            return next err if err
            outMails = []

            # forEach inbox
            async.each inboxes, (inbox, callback) ->

                query =
                    startkey: [inbox.id, timestamp]
                    endkey: [inbox.id]
                    limit: limit
                    descending: true

                # get num mails
                Mail.fromFolderByDate query, (err, mails) ->
                    if err
                        console.log err
                        callback err
                    else
                        outMails.push mail for mail in mails
                        callback null

            , (err) ->
                return next err if err

                # sort by dateValueOf descending
                outMails.sort (a, b) -> return b.dateValueOf - a.dateValueOf
                i = 0
                while outMails[i].dateValueOf > timestamp
                    i++

                # send only the 100 latest
                send outMails[i..i+99]


action 'getattachment', ->

    stream = @mail.getFile params.filename, (err, res, body) ->
        return handle err if err or not res or res.statusCode isnt 200
        return handle 'File not found', 404 if res.statusCode is 404

    stream.pipe res
