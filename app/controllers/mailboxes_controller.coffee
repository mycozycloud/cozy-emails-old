before ->
  Mailbox.find req.params.id, (err, box) =>
    if err or !box
      send 403
    else
      @box = box
      next()
, { only: ['índex', 'show', 'update', 'destroy'] }

# GET /mailboxes
action 'index', ->
  Mailbox.all (err, boxes) ->
    send boxes

# POST /mailboxes
action 'create', ->
  Mailbox.create req.body, (error) =>
    if !error
      send 200
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
      send 200
    else
      send 500

# DELETE /mailboxes/:id
action 'destroy', ->
  @box.destroy (error) =>
    if !error
      send 200
    else
      send 500