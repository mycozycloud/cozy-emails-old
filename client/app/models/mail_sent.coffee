BaseModel = require("./models").BaseModel

###
  @file: mail_sent.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Model which defines the sent MAIL object.

###
class exports.MailSent extends BaseModel

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @
    
  mailbox: ->
    if not @mailbox
      @mailbox = window.app.mailboxes.get @get "mailbox"
    @mailbox

  getColor: ->
    box = window.app.mailboxes.get @get "mailbox"
    if box
      box.get "color"
    else
      "white"
      
  redrawView: ->
    @view.render() if @view?

  removeView: ->
    @view.remove() if @view?
    
  ###
      RENDERING - these functions attr() replace @get "attr", and add some parsing logic.
      To be used in views, to keep the maximum of logic related to mails in one place.
  ###

  cc: ->
    out = ""
    if @get "cc"
      parsed = JSON.parse @get "cc"
      for obj in parsed
        out += obj.name + " <" + obj.address + ">, "
    out

  ccShort: ->
    out = ""
    if @get "cc"
      parsed = JSON.parse @get "cc"
      for obj in parsed
        out += obj.name + " "
    out
    
  to: ->
    out = ""
    if @get "to"
      parsed = JSON.parse @get "to"
      for obj in parsed
        out += obj.name + " <" + obj.address + ">, "
    out

  toShort: ->
    out = ""
    if @get "to"
      parsed = JSON.parse @get "to"
      for obj in parsed
        if obj.name
          out += obj.name + ", "
        else
          out += obj.address + ", "
    out

  date: ->
    parsed = new Date @get("sentAt")
    parsed.toUTCString()

  text: ->
    @get("text").replace(/\r\n|\r|\n/g, "<br />")

  html: ->
    expression = new RegExp("(<style>(.|\s)*?</style>)", "gi");
    exp = ///
      /(<style>(.|\s)*?</style>)/ig
      ///
    string = new String @get("html")
    string.replace(expression,"")
    
  hasHtml: ->
    html = @get "html"
    html? and html != ""
    
  hasText: ->
    text = @get "text"
    text? and text != ""
    
  hasAttachments: ->
    @get "hasAttachments"

  htmlOrText: ->
    if @hasHtml()
      @html()
    else
      @text()
      
  textOrHtml: ->
    if @hasText()
      @text()
    else
      @html()
      