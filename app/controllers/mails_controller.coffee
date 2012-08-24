###
  @file: mails_controller.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Railwayjs controller to handle mails CRUD backend and their attachments.
###

# shared functionnality : find the mail via its ID
before ->
  Mail.find req.params.id, (err, box) =>
    if err or !box
      send 403
    else
      @box = box
      next()
, { only: ['show', 'update', 'destroy'] }

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
  console.log {where : {"dateValueOf" : {lt : timestamp}}, limit : num, order: 'dateValueOf DESC'}
  Mail.all {where : {"dateValueOf" : {lt : timestamp}}, limit : num, order: 'dateValueOf DESC'}, (error, mails) ->
    if !error
      send mails
    else
      send 500
      
# GET '/mailsnew/:timestamp'
action 'getnewlist', ->
  num = parseInt req.params.num
  timestamp = parseInt req.params.timestamp
  console.log {where : {"dateValueOf" : {gt : timestamp}}, order: 'dateValueOf ASC'}
  Mail.all {where : {"dateValueOf" : {gt : timestamp}}, order: 'dateValueOf ASC'}, (error, mails) ->
    if !error
      send mails
    else
      send 500

# GET '/getattachments/:mail
action 'getattachmentslist', ->
  Mail.find req.params.mail, (err, box) =>
    if err or !box
      send 403
    else
      box.attachments (error, attachments) =>
        if error
          send 403
        else
          send attachments
          
# GET '/getattachment/:attachment'
action 'getattachment', ->
  Attachment.find req.params.attachment, (err, box) =>
    if err or !box
      send 403
    else
      header "Content-Type", "application/force-download"
      header "Content-Disposition", 'attachment; filename="' + box.fileName + '"'
      header "Content-Length", box.length
      # console.log box.contentType
      # console.log box.length
      # buf = new Buffer box.content64
      # res.write buf.toString("binary"), "binary"
      res.end()