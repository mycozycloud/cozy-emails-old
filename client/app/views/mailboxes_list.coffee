{Mailbox} = require "../models/mailbox"

{MailboxesListElement} = require "../views/mailboxes_list_element"

###

  Displays the list of configured mailboxes.

###
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
    box = new MailboxesListElement mail, mail.collection
    $(@el).append box.render().el    

  render: ->
    $(@el).html ""
    @collection.each (m) =>
      m.isEdit = false
      @addOne m
    @