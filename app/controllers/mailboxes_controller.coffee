###
    @file: mailboxes_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller to handle mailboxes CRUD backend plus a gateway to
        send mails via a mailbox.
###

mimelib = require "mimelib"
async = require "async"


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

    Mailbox.all (err, boxes) ->
        if err
            console.log "[Mailbox.all] err: #{err}"
            return send 500

        boxes = [] unless boxes

        async.eachSeries boxes, (box, cb) ->

            box.getAccount (err, account) ->
                console.log "[addPassword] err: #{err}" if err

                box.password = account.password if account

                cb()

        , (err) ->
            if err
                send "Can't decrypt password", 500
            else
                send boxes


# POST /mailboxes
# Create a new mailbox and start a new import.
action 'create', ->
    password = body.password
    delete body.password

    Mailbox.findByEmail body.login, (err, box) ->
        return send error: err, 500 if err
        return send error: "Box already exists", 400 if box?

        Mailbox.create body, (err, mailbox) ->
            return send error: err, 500 if err

            mailbox.createAccount password: password, (err, account) ->
                return send error: "Cannot save box password", 500 if err

                send mailbox
                mailbox.fullImport()


# GET /mailboxes/:id
# Get mailbox with given id and set decrypted password on it.
action 'show', ->

    send @box

    # @box.getFolders (err, folders) =>

    #     @box.folders = folders

    #     send @box


    # @box.getAccount (err, account) =>
    #     # realtime requests for the box occurs before the
    #     # account have been set, send the box anyway
    #     # it will get updated when the createAccount complete
    #      if err or not account

    #     @box.password = account.password

action 'folders', ->

    Folder.all (err, folders) ->
        return send error: err, 500 if err
        send folders



# PUT /mailboxes/:id
# Save given mailbox changes and start a new import if previous one did not
# finished succesfully.
action 'update', ->
    password = body.password
    delete body.password

    @box.updateAttributes body, (err) =>
        return send error: true, 500 if err

        @box.getAccount (err, account) =>
            return send error: true, 500 if err
            if password is account.password
                send success: true
                @box.fullImport() unless @box.status in ["imported","importing"]
                return

            # if the password has changed, update the account
            @box.mergeAccount password: password, (err) =>
                return send error: true, 500 if err

                send success: true

                @box.fullImport() unless @box.status in ["imported","importing"]


# DELETE /mailboxes/:id
# Delete given mailbox and all related stuff (mails, attachments...)
action 'destroy', ->
    if @box.status is "importing"
        return send error: "Cannot delete a mailbox while importing", 400

    @box.remove (err) ->
        if err then send error: err, 500
        else send sucess: true, 204

# POST /sendmail
action 'sendmail', ->
    body.createdAt = new Date().valueOf()
    @box.sendMail body, (err) =>
        return send error: err, 500 if err

        body.to = JSON.stringify mimelib.parseAddresses data.to
        body.bcc = JSON.stringify mimelib.parseAddresses data.bcc
        body.cc = JSON.stringify mimelib.parseAddresses data.cc

        body.mailbox = @box.id
        body.sentAt = new Date().valueOf()
        body.from = @box.smtpSendAs

        MailSent.create body, (err) =>
            if err then send error: err, 500
            else send sucess: true, 204


# Get account information for all mailbox (decrypted passwords) and load last
# mails (+ synchronize last recieved mails). Do nothing if the mailbox is not
# fully imported.
action 'fetchNew', ->

    Mailbox.all (err, boxes) ->

        return send error: err, 500 if err

        boxes = [] unless boxes

        async.eachSeries boxes, (box, callback) -> # for each box
            return callback() if box.status isnt "imported"

            Folder.fromMailBox box.id, (err, folders) ->
                return callback err if err

                async.eachSeries box.folders, (folder, cb) ->
                    box.getNewMails folder.path, 200, cb
                , callback

        , (err) -> # once all box have been processed
            if err then send error: err, 500
            else        send success: true