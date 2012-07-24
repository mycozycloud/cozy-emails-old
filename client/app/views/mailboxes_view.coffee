{MailboxView} = require "./mailbox_view"

class exports.MailboxesList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"
    
  constructor: (@el, @collection) ->
    super()

  # events: {
  #   "click #add_mailbox" : 'addMailbox',
  # }

  initialize: ->
    @collection.fetch()
    @collection.add [
      "name": "miko", server: "s1"
    ,
      "name": "miko2", server: "s2"
    ]
  # Add a line at the bottom of the list.
  addOne: (mail) ->
    box = new MailboxView mail, mail.collection
    $("#mail_list_container").append box.render().el

  render: ->
    @collection.each @addOne
    # $("#mail_list_container").html "lama lama"
    @