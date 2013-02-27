{Mail} = require "../models/mail"

###
    @file: mails_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The element on the list of mails. Reacts for events, and stuff.

###

class exports.MailsListElement extends Backbone.View

    tagName : "tr"
    active: false
    visible: true
    
    events :
        "click": "setActiveMail"
    
    constructor: (@model, @collection) ->
        super()
        @model.view = @
        window.app.appView.mailboxes.on "change_active_mailboxes", @checkVisible, @
        
    setActiveMail: (event) ->
        @collection.setActiveMail @model
        @render()
        @collection.setActiveMailAsRead @model
        @collection.trigger "change_active_mail"
    
    checkVisible: ->
        state = @model.get("mailbox") in window.app.appView.mailboxes.activeMailboxes
        if state isnt @visible
            @visible = state
            @render()
            
    render: ->
        @visible = @model.get("mailbox") in window.app.appView.mailboxes.activeMailboxes
        template = require('./templates/_mail/mail_list')
        @$el.html template
            model: @model
            active: @active
            visible: @visible
        @
