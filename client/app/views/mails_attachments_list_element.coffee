###

  The element on the list of mails. Reacts for events, and stuff.

###
class exports.MailsAttachmentsListElement extends Backbone.View

  tagName : "p"
  
  constructor: (@attachment) ->
    super()
    @attachment.view = @
    
  render: ->
    template = require('./templates/_attachment/attachment_element')
    $(@el).html template({"attachment" : @attachment})
    @