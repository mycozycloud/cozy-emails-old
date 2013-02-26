{AttachmentsCollection} = require "../collections/attachments"
{MailsAttachmentsListElement} = require "./mails_attachments_list_element"

###
    @file: mails_attachments_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The list of attachments, created every time user displays a mail.
###

class exports.MailsAttachmentsList extends Backbone.View
    
    constructor: (@el, @model) ->
        super()
        
    initialize: ->
        @collection = new AttachmentsCollection @model

        @collection.on 'reset', @render, @
        @collection.on 'add', @addOne, @
        @$el.html "loading..."
        @$el.spin "small"
        @collection.fetch()
    
    addOne: (attachment) ->
        box = new MailsAttachmentsListElement attachment, @collection
        @$el.append box.render().el

    render: ->
        @$el.html ""
        @collection.each (attachment) =>
            @addOne attachment
        @
