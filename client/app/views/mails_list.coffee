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
    @collection.fetchOlder()
    
    @collection.on "add", @treatAdd, @
    window.app.mailboxes.updateActiveMailboxes()

  treatAdd: (mail) ->

    dateCreatedAt = new Date(mail.get("createdAt")).valueOf()
    
    # check if we are adding a new message, or an old one
    if dateCreatedAt <= window.app.mails.timestampMiddle
      # update timestamp for the list of messages
      if dateCreatedAt < window.app.mails.timestampOld
        window.app.mails.timestampOld = dateCreatedAt
    
      # add its view at the bottom of the list
      @addOne mail
    else
      # update timestamp for new messages
      if dateCreatedAt > window.app.mails.timestampNew
        window.app.mails.timestampNew = dateCreatedAt
      
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