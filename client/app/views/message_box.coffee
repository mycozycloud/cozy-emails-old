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

    # Add a mailbox at the top of the list.
    renderOne: (logmessage) ->
        @updateLastLogDate logmessage
        if logmessage.get("subtype") is "check" and
        logmessage.get("type") is "info"
            @changeLastCheckedDate logmessage
            @keepOnlyLastCheckLog logmessage
        else
            @addNewBox logmessage

    # Change the last check date displayed to user.
    changeLastCheckedDate: (logmessage) ->
        date = new Date logmessage.get 'createdAt'
        mailsList = window.app.viewMailsList
        mailsList.viewMailsListNew.changeGetNewMailLabel date if mailsList?

    # Only last log is relevelant for check logs, so we keep only that one.
    keepOnlyLastCheckLog: (logmessage) ->
        if @previousCheckMessage?
            @collection.remove @previousCheckMessage
            @previousCheckMessage.destroy()
        @previousCheckMessage = logmessage

    # Add a new box widget to UI.
    addNewBox: (logmessage) ->
        box = new MessageBoxElement logmessage, @collection
        @$el.prepend box.render().el

    # Register date of last log date, that's useful to retrieve new logs only.
    updateLastLogDate: (logmessage) ->
        if Number(logmessage.get "createdAt") > Number(@collection.lastCreatedAt)
            @collection.lastCreatedAt = Number(logmessage.get "createdAt") + 2

    render: ->
        @previousCheckMessage = null
        @collection.each (message) =>
            @renderOne message
        @
