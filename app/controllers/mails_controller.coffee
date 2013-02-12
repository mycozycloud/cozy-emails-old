###
    @file: mails_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Railwayjs controller to handle mails CRUD backend and their attachments.
###

load 'application'

action 'index', ->
    render
        title: "CozyMails"

# shared functionnality : find the mail via its ID
before ->
    Mail.find req.params.id, (err, box) =>
        if err or !box
            send 404
        else
            @box = box
            next()
, { only: ['show', 'update', 'destroy', 'getattachmentslist'] }

# GET /mails/:id
action 'show', ->
    send @box

# PUT /mails/:id
action 'update', ->
    data = {}
    attrs = [
        "flags",
        "flagged",
        "read"
    ]
    
    for attr in attrs
        data[attr] = req.body[attr]
        
    @box.updateAttributes data, (error) =>
        if !error
            send 200
        else
            send 500

# DELETE /mails/:id
action 'destroy', ->
    @box.destroy (error) =>
        if !error
            send 200
        else
            send 500
            
# GET '/mailslist/:timestamp.:num'
action 'getlist', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp
    
    if params.id? and params.id != "undefined"
        skip = 1
    else
        skip = 0

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        skip: skip

    Mail.dateId query, (error, mails) ->
        if !error
            # we send 204 when there is no content to send
            if mails.length == 0
                send 499
            else
                send mails
        else
            send 500
            
# GET '/mailssentlist/:timestamp.:num'
action 'getlistsent', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp

    if params.id? and params.id != "undefined"
        skip = 1
    else
        skip = 0

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        skip: skip

    MailSent.dateId query, (error, mails) ->
        if !error
            # we send 204 when there is no content to send
            if mails.length == 0
                send 499
            else
                send mails
        else
            send 500
            
# GET '/mailsnew/:timestamp'
action 'getnewlist', ->
    timestamp = parseInt req.params.timestamp

    if params.id? and params.id != "undefined"
        skip = 1
    else
        skip = 0
        
    query =
        startkey: [timestamp]
        skip: skip
        descending: false
        
    Mail.dateId query, (error, mails) ->
        console.log mails
        console.log query
        if !error
            send mails
        else
            send 500

# GET '/getattachments/:id
action 'getattachmentslist', ->
    query =
        key: @box.id
    Attachment.fromMail query, (error, attachments) ->
        if error
            console.log error
            console.log attachments
            send 500
        else
            send attachments
                    
# GET '/getattachment/:attachment'
action 'getattachment', ->
    Attachment.find req.params.attachment, (err, attachment) =>
        if err or not attachment
            send 404
        else
            attachment.getFile attachment.fileName, (err, res, body) ->
                if err or not res?
                    send 500
                else if res.statusCode is 404
                    send 'File not found', 404
                else if res.statusCode != 200
                    send 500
                else
                    send 200
            .pipe response
