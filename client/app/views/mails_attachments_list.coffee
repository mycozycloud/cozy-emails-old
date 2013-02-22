{Attachment} = require "../models/attachment"
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
    
  initialize: () ->
    window.app.attachments.on 'reset', @render, @
    window.app.attachments.on 'add', @addOne, @
    window.app.attachments.setModel @model
    @$el.html "loading..."
    @$el.spin "small"
    window.app.attachments.fetch()
  
  addOne: (attachment) ->
    box = new MailsAttachmentsListElement attachment, @collection
    $(@el).append box.render().el

  render: ->
    $(@el).html ""
    window.app.attachments.each (attachment) =>
      @addOne attachment
    @
