{LogMessage} = require "../models/logmessage"

###
  @file: logmessages.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Backbone collection for holding log messages objects.
###

class exports.LogMessagesCollection extends Backbone.Collection
    
  model: LogMessage
  url: 'getlogs'

  comparator: (msg) ->
    msg.get("createdAt")
    
  initialize: ->
    @fetchNew()
    setInterval @fetchNew, 0.5 * 60 * 1000

  # fetches new log messages from server
  fetchNew: () =>
    console.log "fetchNewLogMessages: " + @url
    #@fetch {add : true}
    @fetch()