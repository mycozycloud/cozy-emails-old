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
    @collection.on "add", @treatAdd, @
    @collection.fetchOlder()
    window.app.mailboxes.updateActiveMailboxes()

  treatAdd: (mail) ->

    dateValueOf = mail.get("dateValueOf")
    
    # check if we are adding a new message, or an old one
    if dateValueOf <= window.app.mails.timestampMiddle
      # update timestamp for the list of messages
      if dateValueOf < window.app.mails.timestampOld
        window.app.mails.timestampOld = dateValueOf
    
      # add its view at the bottom of the list
      @addOne mail
    else
      # update timestamp for new messages
      if dateValueOf > window.app.mails.timestampNew
        window.app.mails.timestampNew = dateValueOf
      
      # add its view on top of the list
      @addNew mail

  addOne: (mail) ->
    mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"))
    box = new MailsListElement mail, mail.collection
    $(@el).append box.render().el
      
  addNew: (mail) ->
    mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"))
    box = new MailsListElement mail, mail.collection
    $(@el).prepend box.render().el

  render: ->
    $(@el).html ""
    col = @collection
    @collection.each (m) =>
      @addOne m
    @