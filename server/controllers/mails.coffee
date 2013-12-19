async = require('async')
Mail = require '../models/mail'
MailFolder = require '../models/mailfolder'

module.exports =


    getMail: (req, res, next, id) ->
        Mail.find id, (err, mail) =>
            if err then next err
            else if not mail?
                res.send error: "mail not found", 404
            else
                req.mail = mail
                next()


    show: (req, res, next) ->
        res.send req.mail


    update: (req, res, next) ->
        markRead = false
        body = req.body
        flagsChanged = req.mail.changedFlags body.flags
        newflags = body.flags

        # flags will be updated after the sync on IMAP succeeds
        delete body.flags

        req.mail.updateAttributes body, (err) =>
            if err then next err
            else
                return res.send success: true, 200 unless flagsChanged

                Mailbox.find req.mail.mailbox, (err, mailbox) =>
                    return next err if err

                    mailbox.syncOneMail req.mail, newflags, (err) =>
                        return next err if err
                        res.send success: true, 200


    destroy: (req, res, next) ->
        Mailbox.find req.mail.mailbox, (err, mailbox) =>
            return next err if err

            mailbox.syncOneMail req.mail, ["\\Deleted"], (err) =>
                return next err if err

                req.mail.destroy (err) =>
                    return next err if err

                    res.send 204


    # res.send num mails from folder id: folderId
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
                res.send mails


    # res.send num mails from the rainbow (merged INBOX folders)
    # starting after timestamp
    # descending order by date
    rainbow: (req, res, next) ->
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
                while outMails.length < i \
                and outMails[i].dateValueOf > timestamp
                    i++

                # res.send only the 100 latest
                res.send outMails[i..i+99]


    getAttachment: (req, res, next) ->
        stream = @mail.getFile params.filename, (err, res, body) ->
            if err
                next err
            else if res.statusCode is 404
                Res.res.send error 'File not found', 404
            else
                stream.pipe res
