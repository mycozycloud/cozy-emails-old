###
    @file: mails_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Railwayjs controller to handle mails CRUD backend and their attachments.
###

load 'application'


# shared functionnality : find the mail via its ID
before ->
    Mail.find req.params.id, (err, box) =>
        if err or !box
            send 404
        else
            @box = box
            next()
, { only: ['show', 'update', 'destroy', 'getattachmentslist'] }


# App entry point
action 'index', ->
    render
        title: "Cozy Mails"


# GET /mails/:id
action 'show', ->
    send @box


# PUT /mails/:id
action 'update', ->
    @box.updateAttributes body, (err) =>
        if err
            send 500
        else
            send 200


# DELETE /mails/:id
action 'destroy', ->
    @box.destroy (err) =>
        if err
            send 500
        else
            send 204
            

# GET '/mailslist/:timestamp.:num'
action 'getlist', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp
    
    if params.id? and params.id isnt "undefined"
        skip = 1
    else
        skip = 0

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        skip: skip

    Mail.dateId query, (err, mails) ->
        if err
            send 500
        else
            if mails.length is 0
                send []
            else
                send mails
            

# GET '/mailssentlist/:timestamp.:num'
action 'getlistsent', ->
    num = parseInt params.num
    timestamp = parseInt params.timestamp

    if params.id? and params.id isnt "undefined"
        skip = 1
    else
        skip = 0

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        skip: skip

    MailSent.dateId query, (err, mails) ->
        if err
            send 500
        else
            send mails

# GET '/mailsnew/:timestamp'
action 'getnewlist', ->
    timestamp = parseInt params.timestamp

    if params.id? and params.id isnt "undefined"
        skip = 1
    else
        skip = 0
        
    query =
        startkey: [timestamp]
        skip: skip
        descending: false
        
    Mail.dateId query, (err, mails) ->
        if err
            send 500
        else
            send mails

# GET '/getattachments/:id
action 'getattachmentslist', ->
    query =
        key: @box.id

    Attachment.fromMail query, (err, attachments) ->
        if err
            send 500
        else
            send attachments
                    
# GET '/attachments/:id'
action 'getattachment', ->
    Attachment.find req.params.id, (err, attachment) =>
        if err
            send 500
        else if not attachment
            send 400
        else
            attachment.getFile attachment.fileName, (err, res, body) ->
                if err or not res?
                    send 500
                else if res.statusCode is 404
                    send 'File not found', 404
                else if res.statusCode isnt 200
                    send 500
                else
                    send 200
            .pipe response
