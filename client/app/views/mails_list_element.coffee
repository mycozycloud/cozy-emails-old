{Mail} = require "../models/mail"

###

  The element on the list of mails. Reacts for events, and stuff.

###
class exports.MailsListElement extends Backbone.View

  tagName : "tr"
  active: false
  visible: true
  
  events :
    "click" : "setActiveMail"
  
  constructor: (@model, @collection) ->
    super()
    @model.view = @
    window.app.mailboxes.on "change_active_mailboxes", @checkVisible, @
    
  setActiveMail: (event) ->
    # deactivate previous one
    @collection.activeMail?.view?.active = false
    @collection.activeMail?.view?.render()
    # update new one, and render
    @collection.activeMail = @model
    @collection.activeMail.view.active = true
    @render()
    # set read and save to server
    @collection.activeMail.set_read()
    @collection.activeMail.url = "mails/" + @collection.activeMail.get("id")
    @collection.activeMail.save({"read" : true})
    # trigger global event
    @collection.trigger "change_active_mail"
  
  checkVisible: () ->
    state = @model.get("mailbox") in window.app.mailboxes.activeMailboxes
    if state != @visible
      @visible = state
      @render()
    
  render: ->
    template = require('./templates/_mail/mail_list')
    $(@el).html template({"model" : @model, "active" : @active, "visible" : @visible})
    @