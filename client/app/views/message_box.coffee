{MessageBoxElement} = require "./message_box_element"
{LogMessage} = require "../models/logmessage"

###
        @file: message_box.coffee
        @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
        @description: 
            Serves a place to display messages which are meant to be seen by user.
###

class exports.MessageBox extends Backbone.View
    
    id: "message_box"

    constructor: (@el, @collection) ->
        super()

    initialize: ->
        @collection.on "add", @renderOne, @
        @collection.on "reset", @render, @

    # Add a mailbox at the bottom of the list
    renderOne: (logmessage) ->
        box = new MessageBoxElement logmessage, @collection

        @$el.prepend box.render().el
        if Number(logmessage.get "createdAt") > Number(@collection.lastCreatedAt)
            @collection.lastCreatedAt = Number(logmessage.get "createdAt") + 1

    render: ->
        @collection.each (message) =>
            @renderOne message
        @
