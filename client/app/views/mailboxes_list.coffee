{Mailbox} = require "../models/mailbox"
{MailboxesListElement} = require "../views/mailboxes_list_element"

###
  @file: mailboxes_list.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
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
