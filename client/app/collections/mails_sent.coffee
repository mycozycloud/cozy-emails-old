{Mail} = require "../models/mail"

###
  @file: mails_sent.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The collection to store sent emails - gets populated with the content of the database.
    Uses standard "resourceful" approcha for API.

###
class exports.MailsSentCollection extends Backbone.Collection
    
  model: Mail
  url: 'mails/'
  
  # timestamps:
  #   * timestampOld - the oldest mail (sort and next quesries ask fof olders ("load more" button))
  timestampOld: new Date().valueOf()
  
  # number of mails to fetch at one click on "more mail" button
  mailsAtOnce: 50
  
  # variable to store number of mails visible in the avtive filter
  mailsShown: 0

  calculateMailsShown: ->
    #TODO
    #window.app.mails.trigger "update_number_mails_shown"
    #@model.get("mailbox") in window.app.mailboxes.activeMailboxes
    @mailsShown = 0
    col = @
    @each (m) =>
      if m.get("mailbox") in window.app.mailboxes.activeMailboxes
        col.mailsShown++
    console.log "updated number of visible mails: " + @mailsShown
    @trigger "updated_number_mails_shown"
  
  # comparator to sort the collection with the date
  comparator: (mail) ->
    - mail.get("createdAt")
  
  initialize: ->
    @on "change_active_mail", @navigateMail, @
    @on "update_number_mails_shown", @calculateMailsShown, @

  # sets the url to the active mail, chosen by user (for browser history to work, for example)
  navigateMail: (event) ->
    if @activeMail?
      window.app.router.navigate "mail/" + @activeMail.id
    else
      console.error "NavigateMail without active mail"
  
  # fetches older mails (the list of mails)
  fetchOlder: (callback, errorCallback) ->
    @url = "mailssentlist/" + @timestampOld + "." + @mailsAtOnce + "/" + @lastIdOld
    console.log "fetchOlder: " + @url
    errorCallback = (error) ->
      console.log error
    @fetch {add : true, success: callback, error: errorCallback}
    