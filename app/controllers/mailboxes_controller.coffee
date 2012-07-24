load 'application'

before ->
  Mailbox.find req.params.id, (err, box) =>
    if err or not box
      send 403
    else
      @box = box
      next()
, only: ['índex', 'show', 'edit', 'update', 'destroy']

# GET /mailboxes
action 'index', ->
  Mailbox.all (err, boxes) ->
    send JSON.stringify(boxes)

# GET /mailboxes/:id
action 'show', ->
    if !@box
      send JSON.stringify(new Mailbox)
    else
      send JSON.stringify(@box)

# PUT /mailboxes/:id
action 'update', ->
  # console.log req.body
  @box.updateAttributes req.body, (error) =>
    if not error
      send 200
    else
      send 403

# DELETE /mailboxes/:id
action 'destroy', ->
  @box.destroy (error) ->
    if not error
      send 200
    else
      send 403