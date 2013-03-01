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
            next()
, only: ['show', 'update', 'destroy',
         'sendmail', 'import', 'fetch', 'fetchandwait']


# GET /mailboxes
action 'index', ->
    Mailbox.all (err, boxes) ->
        if err
            send 500
        else
            send boxes


# POST /mailboxes
action 'create', ->
    Mailbox.create body, (err, mailbox) =>
        if err
            send 500
        else
            mailbox.setupImport (err) =>
                mailbox.doImport() unless err
            send mailbox


# GET /mailboxes/:id
action 'show', ->
    if not @box
        send new Mailbox
    else
        send @box


# PUT /mailboxes/:id
action 'update', ->
    @box.updateAttributes body, (err) =>
        if err
            send 500
        else
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
                @box.destroy (err) ->
                    send 204

# post /sendmail
action 'sendmail', ->
    body.createdAt = new Date().valueOf()
       
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
            

# get /fetchmailbox/:id
action 'fetch', ->
    app.createCheckJob @box.id, (err) ->
        if not err
            send success: true
        else
            send 500


# get /fetchmailboxandwait/:id
action 'fetchandwait', ->
    # fake job object
    job =
        progress: (at, from) ->
            console.log "Fetch and wait progress: #{at / from*100}%"
        data:
            title: "fake job"
            mailboxId: @box.id

    @box.getNewMail 250, job, (err) ->
        if not err
            send success: true
        else
            send 500
