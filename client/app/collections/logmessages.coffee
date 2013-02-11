{LogMessage} = require "../models/logmessage"

###
  @file: logmessages.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Backbone collection for holding log messages objects.
###

class exports.LogMessagesCollection extends Backbone.Collection
    
  model: LogMessage
  lastCreatedAt: 0
  url: 'getlogs'

  comparator: (msg) ->
    msg.get "createdAt"
    
  initialize: ->
    @fetchNew()
    setInterval @fetchNew, 5 * 1000

  # fetches new log messages from server
  fetchNew: () =>
    @fetch
        add : true
        url: 'getlogs/' + @lastCreatedAt
        success: =>
            @reset()
