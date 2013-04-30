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
    urlRoot: 'logs'

    comparator: (msg) ->
        msg.get "createdAt"

    initialize: ->
        @fetchNew()
        setInterval @fetchNew, 5 * 1000

    # fetches new log messages from server
    fetchNew: =>
        @url = "#{@urlRoot}/#{@lastCreatedAt}"
        @fetch
            add: true
            success: (models) =>
                if models.length > 0
                    @lastCreatedAt = models.last().get "createdAt"
