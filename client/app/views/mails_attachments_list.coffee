{Attachment} = require "../models/attachment"
{AttachmentsCollection} = require "../collections/attachments"
{MailsAttachmentsListElement} = require "./mails_attachments_list_element"
###

###
class exports.MailsAttachmentsList extends Backbone.View
  
  constructor: (@el, @model) ->
    super()
    
  initialize: () ->
    window.app.attachments.on 'reset', @render, @
    window.app.attachments.on 'add', @addOne, @
    window.app.attachments.setModel @model
  
  addOne: (attachment) ->
    box = new MailsAttachmentsListElement attachment, @collection
    $(@el).append box.render().el

  render: ->
    $(@el).html ""
    window.app.attachments.each (attachment) =>
      @addOne attachment
    @