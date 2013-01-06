{Mailbox} = require "../models/mailbox"

###
  @file: mailboxes.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Generic collection of all mailboxes configured by user.
    Uses standard "resourceful" approach for DB API, via it's url.

###
class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  activeMailboxes: []
  
  initialize: ->
    @on "add", @addView, @

  comparator: (mailbox) ->
    mailbox.get("name")
    
  addView: (mail) ->
    @view.addOne(mail) if @view?
  
  # function fired when user changes the set of active mailboxes - to rerender the list (filter it)
  updateActiveMailboxes: ->
    @activeMailboxes = []
    @each (mb) =>
      if mb.get("checked")
        @activeMailboxes.push mb.get("id")
    
    console.log "update mailboxes: " + @activeMailboxes
    @trigger "change_active_mailboxes", @
    
    window.app.mails.trigger "update_number_mails_shown"
    window.app.mailssent.trigger "update_number_mails_shown"
