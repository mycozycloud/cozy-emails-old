{Mail} = require "../models/mail"

{MailsListElement} = require "./mails_list_element"

###

  View to generate the list of mails - the second column from the left.
  Uses MailsListElement to generate each mail's view

###
class exports.MailsList extends Backbone.View
  id: "mails_list"

  constructor: (@el, @collection) ->
    super()
    @collection.view = @

  initialize: ->
    @collection.on('reset', @render, @)
    @collection.on('add', @addOne, @)
    window.app.mailboxes.on('change_active_mailboxes', @render, @)
    @collection.fetchOlder()

  addOne: (mail) ->
    if mail.get("mailbox") in window.app.mailboxes.activeMailboxes
      mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"))
      box = new MailsListElement mail, mail.collection
      $(@el).append box.render().el
      
  addNew: (mail) ->
    if mail.get("mailbox") in window.app.mailboxes.activeMailboxes
      mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"))
      box = new MailsListElement mail, mail.collection
      $(@el).prepend box.render().el

  render: ->
    $(@el).html ""
    col = @collection
    @collection.each (m) =>
      @addOne m
    @