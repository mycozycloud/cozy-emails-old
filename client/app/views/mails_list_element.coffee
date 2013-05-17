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

    setActiveMail: (event) ->
        @collection.setActiveMail @model
        $(".table tr").removeClass "active"
        @$el.addClass "active"
        @collection.setActiveMailAsRead() if not @model.get 'read'
        @collection.trigger "change_active_mail"

    checkVisible: ->
        @render()

    render: ->
        mailbox = window.app.appView.mailboxes.get @model.get("mailbox")
        data =
            model: @model
        if mailbox?
            data.mailboxName = mailbox.get("name")
        else
            data.mailboxName = ""

        template = require('./templates/_mail/mail_list')
        @$el.html template(data)
        @
