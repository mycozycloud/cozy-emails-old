{MailboxView} = require "./mailbox_view"
{Mailbox} = require "../models/mailbox"

class exports.MailboxesList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"

  events: {
     "click #add_mailbox" : 'addMailbox',
  }

  constructor: (@el, @collection) ->
    super()
    @collection.view = @

  initialize: ->
    @collection.on('reset', @render, @)

  # Action when user clicks on new mailbox
  addMailbox: (event) ->
    event.preventDefault()
    newbox = new Mailbox
    @collection.add newbox
    @addOne newbox, true

  # Add a mailbox at the bottom of the list
  addOne: (mail, edit = false) ->
    mail.isEdit = edit
    box = new MailboxView mail, mail.collection
    @.$("#mail_list_container").append box.render().el    

  render: ->
    @.$("#mail_list_container").html("")
    @collection.each (mail) =>
      @addOne mail, false
    @.$("#mail_list_container")