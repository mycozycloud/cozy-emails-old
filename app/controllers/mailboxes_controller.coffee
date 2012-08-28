###
  @file: mailboxes_controller.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Railwayjs controller to handle mailboxes CRUD backend plus a gateway to send mails via a mailbox.
###

load "application"

# shared functionnality : find the mailbox via its ID
before ->
  Mailbox.find req.params.id, (err, box) =>
    if err or !box
      send 404
    else
      @box = box
      next()
, { only: ['show', 'update', 'destroy', 'sendmail', 'import', 'fetch'] }

# GET /mailboxes
action 'index', ->
  Mailbox.all (err, boxes) ->
    send boxes

# POST /mailboxes
action 'create', ->
  Mailbox.create req.body, (error, mailbox) =>
    if !error
      # mailbox.success = true
      send mailbox
    else
      send 500

# GET /mailboxes/:id
action 'show', ->
    if !@box
      send new Mailbox
    else
      send @box

# PUT /mailboxes/:id
action 'update', ->
  data = {}
  attrs = [
    "checked",
    "config",
    "name",
    "login",
    "pass",
    "SMTP_server",
    "SMTP_ssl",
    "SMTP_send_as",
    "IMAP_server",
    "IMAP_port",
    "IMAP_secure",
    "color"
  ]
  
  for attr in attrs
    data[attr] = req.body[attr]
    
  @box.updateAttributes data, (error) =>
    if !error
      send {success: true}
    else
      send 500

# DELETE /mailboxes/:id
action 'destroy', ->
  @box.mails.destroyAll (error) =>
    @box.destroy (error) ->
      if !error
        send 200
      else
        send 500
      

# post /sendmail
action 'sendmail', ->
  data = {}
  attrs = [
    "to",
    "subject",
    "html",
    "cc",
    "bcc"
  ]
  
  for attr in attrs
    data[attr] = req.body[attr]
    
  @box.sendMail data, (error) =>
    if !error
      send {success: true}
    else
      send 500
      

# get /importmailbox/:id
action 'import', ->
    if !@box
      send 500
    else
      app.createImportJob @box
      send {success: true}


# get /fetchmailbox/:id
action 'fetch', ->
    if !@box
      send 500
    else
      app.createCheckJob @box, (error) ->
        if not error
          send {success: true}
        else
          send 500
