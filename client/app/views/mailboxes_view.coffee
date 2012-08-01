{MailboxView} = require "./mailbox_view"
{Mailbox} = require "../models/mailbox"

class exports.MailboxesList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"

  constructor: (@el, @collection) ->
    super()
    @collection.view = @

  initialize: ->
    @collection.on('reset', @render, @)
    @collection.fetch()

  # Add a mailbox at the bottom of the list
  addOne: (mail) ->
    box = new MailboxView mail, mail.collection
    $(@el).append box.render().el    

  render: ->
    $(@el).html ""
    @collection.each (m) =>
      m.isEdit = false
      @addOne m
    @