{Mailbox} = require "../models/mailbox"


class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'

  comparator: (Mailbox) ->
    Mailbox.get("name")