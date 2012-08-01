{Mailbox} = require "../models/mailbox"

###

  The toolbar to add a new mailbox.
  
  mailboxes_list -> mailboxes_list_new

###
class exports.MailboxesListNew extends Backbone.View
  
  id: "mailboxeslist_new"
  className: "mailboxes_new"

  events: {
     "click #add_mailbox" : 'addMailbox',
  }

  constructor: (@el, @collection) ->
    super()

  # Action when user clicks on new mailbox
  addMailbox: (event) ->
    event.preventDefault()
    newbox = new Mailbox
    newbox.isEdit = true
    @collection.add newbox

  render: ->
    $(@el).html require('./templates/_mailbox/mailbox_new')
    @