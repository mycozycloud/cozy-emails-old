{MailboxView} = require "./mailbox_view"
{Mailbox} = require "../models/mailbox"

class exports.MailboxesList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"
    
  constructor: (@el, @collection) ->
    super()
    window.app.mailboxes.on('reset', @render, @)
    
  events: {
     "click #add_mailbox" : 'addMailbox',
  }

  initialize: ->
    @collection.fetch()
    
  addMailbox: (event) ->
    event.preventDefault()
    newbox = new Mailbox
    @collection.add newbox
    @addNew newbox
    
  # Add a line at the bottom of the list.
  addOne: (mail) ->
    box = new MailboxView mail, mail.collection
    mail.isEdit = false
    $("#mail_list_container").append box.render().el
    
  addNew: (mail) ->
    box = new MailboxView mail, mail.collection
    mail.isEdit = true
    $("#mail_list_container").append box.render().el    

  render: ->
    $("#mail_list_container").html("")
    @collection.each @addOne
    $("#mail_list_container")