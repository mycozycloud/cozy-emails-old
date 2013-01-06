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
  # schedule un check
  # app.createCheckJobs()

  timestamp = parseInt req.params.timestamp

  if params.id? and params.id != "undefined"
    skip = 1
  else
    skip = 0
    
  query =
      startkey: [timestamp]
      # endkey: [timestamp]
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
  console.log query
  Attachment.fromMail query, (error, attachments) ->
    if error
      console.log error
      console.log attachments
      send 500
    else
      send attachments
          
# GET '/getattachment/:attachment'
action 'getattachment', ->
  Attachment.find req.params.attachment, (err, box) =>
    if err or !box
      send 404
    else
      header "Content-Type", "application/force-download"
      header "Content-Disposition", 'attachment; filename="' + box.fileName + '"'
      header "Content-Length", box.length
      # console.log box.contentType
      # console.log box.length
      # buf = new Buffer box.content64
      # res.write buf.toString("binary"), "binary"
      res.end()
