###
    @file: mails_attachments_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Renders clickable attachments link.
###
class exports.MailsAttachmentsListElement extends Backbone.View

    constructor: (@attachment) ->
        super()
        @attachment.view = @
        
    render: ->
        template = require './templates/_attachment/attachment_element'
        @$el.html template attachment: @attachment
        @
