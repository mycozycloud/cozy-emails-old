{MailboxView} = require "./mailbox_view"
{Mailbox} = require "../models/mailbox"

class exports.MailboxesList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"
    
  constructor: (@el, @collection) ->
    super()
    window.app.mailboxes.on('reset', @render, @)
    window.app.mailboxes.on('add', @render, @)
    window.app.mailboxes.on('remove', @render, @)
    window.app.mailboxes.on('change', @render, @)
    
  events: {
     "click #add_mailbox" : 'addMailbox',
  }

  initialize: ->
    @collection.fetch()
    
  addMailbox: (event) ->
    event.preventDefault()
    newbox = new Mailbox
    @collection.create newbox
    @addNew newbox
    
  # Add a line at the bottom of the list.
  addOne: (mail) ->
    box = new MailboxView mail, mail.collection
    $("#mail_list_container").append box.render().el
    
  addNew: (mail) ->
    box = new MailboxView mail, mail.collection
    box.isEdit = true
    $("#mail_list_container").append box.render().el    

  render: ->
    @collection.fetch()
    $("#mail_list_container").html("")
    @collection.each @addOne
    # $("#mail_list_container").html "lama lama"
    $("#mail_list_container")