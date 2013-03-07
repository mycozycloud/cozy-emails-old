###
    @file: mailboxes_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller to handle mailboxes CRUD backend plus a gateway to
        send mails via a mailbox.
###

load "application"

mimelib = require "mimelib"

# shared functionnality : find the mailbox via its ID
before ->
    Mailbox.find req.params.id, (err, box) =>
        if err
            send 500
        else if not box
            send 404
        else
            @box = box
            @box.getAccount (err) =>
                if err
                    send 500
            next()
, only: ['show', 'update', 'destroy',
         'sendmail', 'import', 'fetch', 'fetchandwait']


# GET /mailboxes
action 'index', ->
    mailboxes = []

    addPassword = (boxes, callback) ->
        if boxes.length > 0
            box = boxes.pop()
            box.getAccount (err, account) =>
                if err
                    callback err
                else
                    box.password = account.password
                    mailboxes.push box
                    addPassword boxes, callback
        else
            callback()

    Mailbox.all (err, boxes) ->
        if err
            send 500
        else
            addPassword boxes, (err) =>
                if err
                    send 500
                else
                    send mailboxes


# POST /mailboxes
action 'create', ->
    password = body.password
    body.password = null
    Mailbox.create body, (err, mailbox) =>
        if err
            send 500
        else
            mailbox.createAccount password: password, (err, account) =>
                if err
                    send 500
                else
                    mailbox.password = account.password
                    mailbox.setupImport (err) =>
                        mailbox.doImport() unless err
                    send mailbox


# GET /mailboxes/:id
action 'show', ->
    if not @box
        send new Mailbox
    else
        @box.getAccount (err, account) =>
            if err
                send 500
            else
                @box.account = account.password
                send @box


# PUT /mailboxes/:id
action 'update', ->
    password = body.password
    delete body.password
    @box.updateAttributes body, (err) =>
        if err
            send 500
        else
            if password isnt @box.password
                @box.password = password
                @box.mergeAccount password: password, (err) =>
                    if err
                        send 500

            unless @box.imported
                @box.setupImport (err) =>
                    @box.doImport() unless err
                send success: true


# DELETE /mailboxes/:id
action 'destroy', ->
    @box.destroyMails (err) =>
        console.log "destroy mails: #{err}" if err
        @box.destroyAttachments (err) =>
            console.log "destroy attachments: #{err}" if err
            @box.destroyMailsToBe (err) =>
                console.log "destroy mailstobe: #{err}" if err
                @box.destroyAccount (err) =>
                    console.log "destroy account: #{err}" if err
                    @box.destroy (err) ->
                        send 204

# post /sendmail
action 'sendmail', ->
    body.createdAt = new Date().valueOf()
    @box.getAccount (err, account) =>
        if err
            send 500
        else
            @box.password = account.password
            @box.sendMail body, (err) =>
                if err
                    send 500
                else
                    body.to = JSON.stringify mimelib.parseAddresses data.to
                    body.bcc = JSON.stringify mimelib.parseAddresses data.bcc
                    body.cc = JSON.stringify mimelib.parseAddresses data.cc

                    body.mailbox = @box.id
                    body.sentAt = new Date().valueOf()
                    body.from = @box.smtpSendAs

                    MailSent.create body, (err) =>
                        if err
                            send 500
                        else
                            send success: true


action 'fetchNew', ->
    fetchBoxes = (boxes, callback) ->
        if boxes.length > 0
            box = boxes.pop()
            box.getAccount (err, account) =>
                if err
                    callback err
                else
                    box.password = account.password
                    if box.imported
                        box.getNewMails 200, (err) ->
                            if err
                                callback err
                            else
                            fetchBoxes boxes, callback
                    else
                        fetchBoxes boxes, callback
        else
            callback()

    Mailbox.all (err, boxes) ->
        if err
            send 500
        else
            fetchBoxes boxes, (err) ->
                if err
                    send 500
                else
                    send 200
