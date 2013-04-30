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
    Mailbox.find params.id, (err, box) =>
        if err
            console.log err
            send 500
        else if not box
            send 404
        else
            @box = box
            @box.getAccount (err, account) =>
                if err
                    console.log err
                else if not account
                    @box.log "no account object set on this mailbox"

                if account?
                    @box.password = account.password
                next()
, only: ['show', 'update', 'destroy',
         'sendmail', 'import', 'fetch', 'fetchandwait']


# GET /mailboxes
# Get the list of mailbox and set account informations (decrypted passwords).
action 'index', ->
    mailboxes = []

    addPassword = (boxes, callback) ->
        if boxes.length > 0
            box = boxes.pop()
            box.getAccount (err, account) =>
                if err
                    console.log "[addPassword] err: #{err}"

                if account?
                    box.password = account.password

                mailboxes.push box
                addPassword boxes, callback
        else
            callback()

    Mailbox.all (err, boxes) ->
        if err
            console.log "[Mailbox.all] err: #{err}"
            send 500
        else
            addPassword boxes, (err) =>
                if err
                    send "Can't decrypt password", 500
                else
                    send mailboxes


# POST /mailboxes
# Create a new mailbox and start a new import.
action 'create', ->
    password = body.password
    body.password = null

    Mailbox.findByEmail body.login, (err, box) ->
        console.log box

        if err then send error: true, 500
        else if box? then send error: "Box already exists", 400
        else
            Mailbox.create body, (err, mailbox) ->
                if err then send error: true, 500
                else
                    mailbox.createAccount password: password, (err, account) ->
                        if err then send error: "Cannot save box password", 500
                        else
                            mailbox.password = password
                            mailbox.setupImport (err) =>
                                mailbox.doImport() unless err
                            send mailbox

# GET /mailboxes/:id
# Get mailbox with given id and set decrypted password on it.
action 'show', ->
    if not @box
        send new Mailbox
    else
        @box.getAccount (account, err) =>
            if err
                send 500
            else if not account
                send 404
            else
                @box.account = account.password
                send @box


# PUT /mailboxes/:id
# Save given mailbox changes and start a new import if previous one did not
# finished succesfully.
action 'update', ->
    password = body.password
    delete body.password

    @box.updateAttributes body, (err) =>
        if err
            send error: true, 500
        else
            @box.getAccount (err, account) =>
                if err
                    send error: true, 500
                else
                    if password isnt account.password
                        @box.password = password
                        @box.mergeAccount password: password, (err) =>
                            if err
                                send error: true, 500
                            else
                                send success: true

                    unless @box.imported or @box.importing
                        @box.setupImport (err) =>
                            @box.doImport() unless err

            send success: true


# DELETE /mailboxes/:id
# Delete given mailbox and all related stuff (mails, attachments...)
action 'destroy', ->
    @box.remove ->
        send sucess: true, 204

# post /sendmail
action 'sendmail', ->
    body.createdAt = new Date().valueOf()
    @box.getAccount (err, account) =>
        if err
            send 500
        else if not account
            send 404
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


# Get account information for all mailbox (decrypted passwords) and load last
# mails (+ synchronize last recieved mails). Do nothing if the mailbox is not
# fully imported.
action 'fetchNew', ->
    fetchBoxes = (boxes, callback) ->
        if boxes.length > 0
            box = boxes.pop()
            box.getAccount (err, account) =>
                if err
                    callback err
                else if not account
                    fetchBoxes boxes, callbacks
                else
                    box.password = account.password
                    if box.imported and not box.importing
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
            console.log err
            send error: true, 500
        else
            fetchBoxes boxes, (err) ->
                if err
                    console.log err
                    send error: true, 500
                else
                    send success: true, 200
