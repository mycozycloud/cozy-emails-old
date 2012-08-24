BaseModel = require("./models").BaseModel

###
  @file: mailbox.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    A model which defines the MAILBOX object.
    MAILBOX stocks all the data necessary for a successful connection to IMAP and SMTP servers,
    and all the data relative to this mailbox, internal to the application.

###
class exports.Mailbox extends BaseModel

  @urlRoot = 'mailboxes/'

  defaults:
    'checked' : true
    'config' : 0
    'name' : "box"
    'login' : "login"
    'pass' : "pass"
    'SMTP_server' : "smtp.gmail.com"
    'SMTP_ssl' : true
    'SMTP_send_as' : "Adam Smith"
    'IMAP_server' : "imap.gmail.com"
    'IMAP_port' : 993
    'IMAP_secure' : true
    'color' : "orange"

  initialize: ->
    @on "destroy", @removeView, @

  removeView: ->
    @view.remove() if @view?
    
  IMAPLastFetchedDate: ->
    parsed = new Date @get("IMAP_last_fetched_date")
    parsed.toUTCString()
