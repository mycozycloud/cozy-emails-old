before ->

  Mail.find req.params.id, (err, box) =>
    if err or !box
      send 403
    else
      @box = box
      next()
, only: ['índex', 'show', 'edit', 'update', 'destroy']

# GET /mailboxes
action 'index', ->
  Mail.all (err, mails) ->
    send mails

# POST /mailboxes
action 'create', ->
  Mail.create req.body, (error) =>
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
  @box.updateAttributes req.body, (error) =>
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