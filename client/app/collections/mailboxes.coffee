{Mailbox} = require "../models/mailbox"

###

  Generic collection of all mailboxes configured by user.
  Uses standard "resourceful" approach for DB API, via it's url.

###
class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  activeMailboxes: []
  
  initialize: ->
    @on "add", @addView, @
    @on "change", @updateActiveMailboxes, @

  comparator: (mailbox) ->
    mailbox.get("name")
    
  addView: (mail) ->
    @view.addOne(mail) if @view?
    
  updateActiveMailboxes: ->
    @activeMailboxes = []
    @each (mb) =>
      if mb.get("checked")
        @activeMailboxes.push mb.get("id")
    
    console.log "update mailboxes: " + @activeMailboxes
    @trigger "change_active_mailboxes", @
