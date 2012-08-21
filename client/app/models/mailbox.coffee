BaseModel = require("./models").BaseModel

###

  A model which defines the MAILBOX object.
  MAILBOX stocks all the data necessary for a successful connection to IMAP and SMTP servers,
  and all the data relative to this mailbox, internal to the application.

###
class exports.Mailbox extends BaseModel

  @urlRoot = 'mailboxes/'

  defaults:
    'checked' : true
    'config' : 0
    'name' : "new mailbox"
    'login' : "login"
    'pass' : "pass"
    'SMTP_server' : "smtp.gmail.com"
    'SMTP_ssl' : true
    'SMTP_send_as' : "Adam Smith"
    'IMAP_server' : "imap.gmail.com"
    'IMAP_port' : 993
    'IMAP_secure' : true
    'color' : "blue"

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @

  removeView: ->
    @view.remove() if @view?

  redrawView: ->
    @view.render() if @view?
    
  IMAP_last_fetched_date: ->
    parsed = new Date @get("IMAP_last_fetched_date")
    parsed.toUTCString()
