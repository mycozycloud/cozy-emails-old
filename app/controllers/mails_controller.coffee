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
  console.log {where : {"createdAt" : {lt : timestamp}}, limit : num, order: 'createdAt DESC'}
  Mail.all {where : {"createdAt" : {lt : timestamp}}, limit : num, order: 'createdAt DESC'}, (error, mails) ->
    if !error
      send mails
    else
      send 500
      
# GET '/mailsnew/:timestamp'
action 'getnewlist', ->
  num = parseInt req.params.num
  timestamp = parseInt req.params.timestamp
  console.log {where : {"createdAt" : {gt : timestamp}}, order: 'createdAt ASC'}
  Mail.all {where : {"createdAt" : {gt : timestamp}}, order: 'createdAt ASC'}, (error, mails) ->
    if !error
      send mails
    else
      send 500