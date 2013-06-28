###
    @file: mails_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The element on the list of mails. Reacts for events, and stuff.

###

class exports.MailsListElement extends Backbone.View

    tagName : "tr"
    className: 'mailslist-element'
    active: false
    visible: true

    events :
        "click"             : "setActiveMail"
        "click .toggleflag" : 'toggleFlag'

    initialize: ->
        super
        @collection = @model.collection
        @listenTo @model, 'change', @render

    setActiveMail: (event) ->
        $(".table tr").removeClass "active"
        @$el.addClass "active"

        unless @model.isRead()
            @model.markRead()
            @model.save()

        window.app.router.navigate "mail/#{@model.get 'id'}", true

    toggleFlag: (event) ->
        event.preventDefault()
        event.stopPropagation()

        @model.markFlagged not @model.isFlagged()
        @model.save({}, ignoreMySocketNotification: true)

    checkVisible: ->
        @render()

    render: ->
        mailboxname = @model.getMailbox()?.get('name') or ''
        data =
            model: @model
            mailboxName: mailboxname

        template = require('templates/_mail/mail_list')
        @$el.html template(data)
        @
