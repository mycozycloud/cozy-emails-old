{Mail} = require "../models/mail"

###

  The collection to store emails - gets populated with the content of the database.
  Uses standard "resourceful" approcha for API.

###
class exports.MailsCollection extends Backbone.Collection
    
  model: Mail
  url: 'mails/'

  comparator: (a, b) ->
    if a.get("date") > b.get("date")
      -1
    else if a.get("date") == b.get("date")
      0
    else
      1
    
  initialize: ->
    @on "change_active_mail", @navigateMail, @

  navigateMail: (event) ->
    window.app.router.navigate "mail/" + @activeMail.id