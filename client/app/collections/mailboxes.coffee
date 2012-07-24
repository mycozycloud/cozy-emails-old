{Mailbox} = require "../models/mailbox"


class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  
  
  removeOne: (mailbox, view) ->
    mailbox.destroy
      success: ->
        view.remove()
      error: ->
        alert "error"
    view.remove()