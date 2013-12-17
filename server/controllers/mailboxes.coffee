mimelib = require "mimelib"
async = require "async"

Mailbox = require '../models/mailbox'


module.exports =


    getMailbox: (req, res, next, id) ->
        Mailbox.find id, (err, box) =>
            if err
                next err
            else if not box
                send error: 'not found', 404
            else
                req.box = box
                req.box.getAccount (err, account) =>
                    if err
                        next err
                    else if not account
                        req.box.log "no account object set on this mailbox"
                        next()
                    else
                        req.box.password = account.password if account?
                        next()


    index: (req, res, next) ->
        mailboxes = []

        Mailbox.all (err, boxes) ->
            if err
                next err

            else
                boxes = [] unless boxes

                async.eachSeries boxes, (box, cb) ->

                    box.getAccount (err, account) ->
                        console.log "[addPassword] err: #{err}" if err
                        box.password = account.password if account
                        cb()

                , (err) ->
                    if err
                        next err
                    else
                        send boxes


    create: (req, res, next) ->
        password = req.body.password
        delete body.password

        Mailbox.findByEmail req.body.login, (err, box) ->
            return send error: err, 500 if err
            return send error: "Box already exists", 400 if box?

            Mailbox.create req.body, (err, mailbox) ->
                return send error: err, 500 if err

                mailbox.createAccount password: password, (err, account) ->
                    return send error: "Cannot save box password", 500 if err

                    send mailbox
                    mailbox.fullImport()


    show: (req, res, next) ->
        send req.box


    update: (req, res, next) ->
        password = body.password
        delete body.password

        req.box.updateAttributes body, (err) =>

            if err then next err
            else
                req.box.getAccount (err, account) =>

                    if err then next err
                    else if password is account.password
                        send success: true
                        unless @box.status in ["imported", "importing"]
                            req.box.fullImport()

                    else

                        req.box.mergeAccount password: password, (err) =>
                            if err then next err
                            else
                                send success: true
                                unless @box.status in ["imported", "importing"]
                                    req.box.fullImport()


    destroy: (req, res, next) ->
        if req.box.status is "importing"
            send error: "Cannot delete a mailbox while importing", 400
        else
            req.box.remove (err) ->
                if err then next err
                else send sucess: true, 204


    sendMail: (req, res, next) ->
        body.createdAt = new Date().valueOf()
        req.box.sendMail body, (err) =>
            if err then next err

                body.to = JSON.stringify mimelib.parseAddresses data.to
                body.bcc = JSON.stringify mimelib.parseAddresses data.bcc
                body.cc = JSON.stringify mimelib.parseAddresses data.cc

                body.mailbox = req.box.id
                body.sentAt = new Date().valueOf()
                body.from = req.box.smtpSendAs

                MailSent.create body, (err) =>
                    if err then next err
                    else send sucess: true, 204


    # Get account information for all mailbox (decrypted passwords) and load last
    # mails (+ synchronize last recieved mails). Do nothing if the mailbox is not
    # fully imported.
    fetchNew: (req, res, next) ->

        Mailbox.all (err, boxes) ->
            if err then next err
            else
                boxes = [] unless boxes

                async.eachSeries boxes, (box, callback) -> # for each box
                    return callback() if box.status isnt "imported"

                    box.getMailGetter (err, getter) ->
                        return callback err if err

                        MailFolder.findByMailbox box.id, (err, folders) ->
                            return callback err if err

                            async.eachSeries folders, (folder, cb) ->
                                folder.getNewMails getter, 200, cb
                            , (err) ->
                                return callback err if err

                                getter.logout callback


                , (err) -> # once all box have been processed
                    console.log err if err
                    if err then next err
                    else send success: true
