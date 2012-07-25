BaseModel = require("./models").BaseModel

# Defines a mailbox
class exports.Mailbox extends BaseModel

  defaults:
    'new_messages' : 1
    'config' : 0
    'name' : "Mailbox"
    'createdAt' : "0"
    'SMTP_server' : "smtp.gmail.com"
    'SMTP_port' : "465"
    'SMTP_login' : "login"
    'SMTP_pass' : "pass"
    'SMTP_send_as' : "You"
  
  deleted: false

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @

  removeView: ->
    @view.remove() if @view?

  redrawView: ->
    @view.render() if @view?