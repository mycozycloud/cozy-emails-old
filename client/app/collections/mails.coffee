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
  timestampMiddle: new Date().valueOf()
  
  mailsAtOnce: 100
  
  mailsShown: 0
  
  zeroMailsShown: ->
    @mailsShown = 0
  
  comparator: (a, b) ->
    if a.get("date") > b.get("date")
      -1
    else if a.get("date") == b.get("date")
      0
    else
      1
    
  initialize: ->
    @on "change_active_mail", @navigateMail, @
    setInterval @fetchNew, 0.5 * 60 * 1000
    
    window.app.mailboxes.on "change_active_mailboxes", @zeroMailsShown, @

  navigateMail: (event) ->
    if @activeMail?
      window.app.router.navigate "mail/" + @activeMail.id
    else
      console.error "NavigateMail without active mail"
  
  # fetches older mails (the list of mails)
  fetchOlder: (callback) ->
    @url = "mailslist/" + @timestampOld + "." + @mailsAtOnce
    console.log "fetchOlder: " + @url
    @fetch {add : true, success: callback}

  # fetches new mails from server
  fetchNew: () =>
    @url = "mailsnew/" + @timestampNew
    console.log "fetchNew: " + @url
    @fetch {add : true}