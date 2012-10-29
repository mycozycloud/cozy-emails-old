###
  @file: logs_controller.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Railwayjs controller for logs system - displaying system information in the interface
###

load 'application'

# shared functionnality : find the mail via its ID
before ->
  LogMessage.find req.params.id, (err, box) =>
    if err or !box
      send 404
    else
      @box = box
      next()
, { only: ['discard'] }
  

# POST '/getlogs'
action 'savelog', ->
  
  data = {}
  attrs = [
    "type",
    "text",
    "createdAt",
    "timeout"
  ]
  
  for attr in attrs
    data[attr] = req.body[attr]
    
  if data["timeout"] == 0    
    LogMessage.create data, (err, box) =>
      if err or !box
        send 500
      else
        send 200
  else
    send 200


# DELETE '/getlogs/:id'
action 'discard', ->
  @box.destroy (error) =>
    if !error
      send 200
    else
      send 500
          
# GET '/getlogs/:createdAt'
action 'getactivelogs', ->
  params =
    startkey: Number req.params.createdAt
    descending: false
    
  LogMessage.request "date", params, (err, logs) =>
    if err
      send 500
    else
      send logs
      # remove those for which timeout > 0
      for log in logs
        if log.timeout != 0
          log.destroy()
