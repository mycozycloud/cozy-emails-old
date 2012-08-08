{Mail} = require "../models/mail"

###

  The collection to store emails - gets populated with the content of the database.
  Uses standard "resourceful" approcha for API.

###
class exports.MailsCollection extends Backbone.Collection
    
  model: Mail
  url: 'mails/'
  
  timestampNew: new Date().valueOf()
  timestampOld: new Date().valueOf()
  
  comparator: (a, b) ->
    if a.get("date") > b.get("date")
      -1
    else if a.get("date") == b.get("date")
      0
    else
      1
    
  initialize: ->
    @on "change_active_mail", @navigateMail, @
    @on "add", @treatAdd, @
    setInterval @fetchNew, 0.5 * 60 * 1000
    
  treatAdd: (model) ->
    # update timestamp for the list of messages
    @timestampOld = new Date(model.get("createdAt")).valueOf() if new Date(model.get("createdAt")).valueOf() < @timestampOld
    
    # update timestamp for new messages
    if new Date(model.get("createdAt")).valueOf() > @timestampNew
      
      @timestampNew = new Date(model.get("createdAt")).valueOf() 
      # update unread numbers
      if model.is_unread()
        box = window.app.mailboxes.get model.get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") + 1)
        # box?.save()
      
  navigateMail: (event) ->
    if @activeMail?
      window.app.router.navigate "mail/" + @activeMail.id
    else
      console.error "NavigateMail without active mail"
  
  # fetches older mails (the list of mails)
  fetchOlder: () ->
    @url = "mailslist/" + @timestampOld + "." + 0
    console.log "fetchOlder: " + @url
    @fetch {add : true}

  # fetches new mails from server
  fetchNew: () =>
    @url = "mailsnew/" + @timestampNew
    console.log "fetchNew: " + @url
    @fetch {add : true}