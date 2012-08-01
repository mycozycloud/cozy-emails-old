{Mailbox} = require "../models/mailbox"

class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  
  initialize: ->
    @on "add", @addView, @

  comparator: (Mailbox) ->
    Mailbox.get("name")
    
  addView: (mail) ->
    @view.addOne(mail) if @view?
    
  setCurrentMailboxes: ->
    
    