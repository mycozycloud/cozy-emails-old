{Mail} = require "../models/mail"

###

  The element on the list of mails. Reacts for events, and stuff.

###
class exports.MailsListElement extends Backbone.View

  tagName : "tr"

  events : {
    "click .choose_mail_button" : "setActiveMail"
  }
  
  constructor: (@model, @collection) ->
    super()
    @model.view = @
    @collection.on "change_active_mail", @render, @
    
  setActiveMail: (event) ->
    @collection.activeMail = @model
    @collection.trigger "change_active_mail"

  render: ->
    template = require('./templates/_mail/mail_list')
    $(@el).html template({"model" : @model.toJSON(), "active" : @model == @collection.activeMail})
    @