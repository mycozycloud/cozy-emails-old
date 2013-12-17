{MailSent} = require "models/mail_sent"

###
  @file: mailssent_list_element.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    The element on the list of mails. Reacts for events, and stuff.

###

class exports.MailsSentListElement extends Backbone.View

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
    # trigger global event
    @collection.trigger "change_active_mail"

  checkVisible: () ->
    state = @model.get("mailbox") in window.app.mailboxes.activeMailboxes
    if state != @visible
      @visible = state
      @render()

  render: ->
    @visible = @model.get("mailbox") in window.app.mailboxes.activeMailboxes
    template = require('templates/_mailsent/mailsent_list')
    $(@el).html template({"model" : @model, "active" : @active, "visible" : @visible})
    @