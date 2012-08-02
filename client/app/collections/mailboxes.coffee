{Mailbox} = require "../models/mailbox"

###

  Generic collection of all mailboxes configured by user.
  Uses standard "resourceful" approach for DB API, via it's url.

###
class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  
  initialize: ->
    @on "add", @addView, @

  comparator: (mailbox) ->
    mailbox.get("name")
    
  addView: (mail) ->
    @view.addOne(mail) if @view?
    
