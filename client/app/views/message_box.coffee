{Mailbox} = require "../models/mailbox"
{Mail} = require "../models/mail"

###

  Displays the list of configured mailboxes.

###
class exports.MessageBox extends Backbone.View

  constructor: (@el, @mailboxes, @mails) ->
    super()

  initialize: ->

  # Add a mailbox at the bottom of the list
  addOne: (mail) ->
    box = new MailboxesListElement mail, mail.collection
    $(@el).append box.render().el    

  render: ->
    template = require('./templates/_message/normal')
    $(@el).html template()
    @
    
  renderMessageSentSuccess: ->
    template = require('./templates/_message/message_sent')
    $(@el).html template()
    @
    
  renderNewMailboxSuccess: ->
    template = require('./templates/_message/new_mailbox')
    $(@el).html template()
    @