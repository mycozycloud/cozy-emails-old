{Mail} = require "../models/mail"

###
  @file: mails.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The collection to store emails - gets populated with the content of the database.
    Uses standard "resourceful" approcha for API.

###
class exports.MailsCollection extends Backbone.Collection
    
  model: Mail
  url: 'mails/'
  
  # timestamps:
  #   * timestampMiddle doesn't change - shows which mails are "new" (fetched after rendering of the interface), and the "old" ones
  #   * timestampNew - the newest mail (sort, and next queries of fetchNew ask for newer)
  #   * timestampOld - the oldest mail (sort and next quesries ask fof olders ("load more" button))
  timestampNew: new Date().valueOf()
  timestampOld: new Date().valueOf()
  timestampMiddle: new Date().valueOf()
  
  # number of mails to fetch at one click on "more mail" button
  mailsAtOnce: 100
  
  # variable to store number of mails visible in the avtive filter
  mailsShown: 0
  
  zeroMailsShown: ->
    @mailsShown = 0
  
  # comparator to sort the collection with the date
  comparator: (mail) ->
    - mail.get("dateValueOf")
  
  initialize: ->
    @on "change_active_mail", @navigateMail, @
    setInterval @fetchNew, 0.5 * 60 * 1000
    
    window.app.mailboxes.on "change_active_mailboxes", @zeroMailsShown, @

  # sets the url to the active mail, chosen by user (for browser history to work, for example)
  navigateMail: (event) ->
    if @activeMail?
      window.app.router.navigate "mail/" + @activeMail.id
    else
      console.error "NavigateMail without active mail"
  
  # fetches older mails (the list of mails)
  fetchOlder: (callback) ->
    @url = "mailslist/" + @timestampOld + "." + @mailsAtOnce + "/" + @lastIdOld
    console.log "fetchOlder: " + @url
    @fetch {add : true, success: callback}

  # fetches new mails from server
  fetchNew: () =>
    @url = "mailsnew/" + @timestampNew + "/" + @lastIdNew
    console.log "fetchNew: " + @url
    @fetch {add : true}
