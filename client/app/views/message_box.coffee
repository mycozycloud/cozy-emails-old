{Mailbox} = require "../models/mailbox"
{Mail} = require "../models/mail"

###
  @file: message_box.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Serves a place to display messages which are meant to be seen by user.
    
    Has a set of preconfigured render methods, used by other views.

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
    
  renderMessageSentError: ->
    template = require('./templates/_message/message_error')
    $(@el).html template()
    @
    
  renderMailboxNewSuccess: ->
    template = require('./templates/_message/mailbox_new')
    $(@el).html template()
    @

  renderMailboxUpdateSuccess: ->
    template = require('./templates/_message/mailbox_update')
    $(@el).html template()
    @