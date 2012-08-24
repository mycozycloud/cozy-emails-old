BaseModel = require("./models").BaseModel

###
  @file: mail.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Model which defines the MAIL object.

###
class exports.Mail extends BaseModel
  
  url: "mails"

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @
    
  removeView: ->
    @view.remove() if @view?

  redrawView: ->
    @view.render() if @view?
    
  mailbox: ->
    window.app.mailboxes.get @get "mailbox"
    
    
    
  ###
      RENDERING - these functions attr() replace @get "attr", and add some parsing logic.
      To be used in views, to keep the maximum of logic related to mails in one place.
  ###

  from: ->
    out = ""
    if @get "from"
      parsed = JSON.parse @get "from"
      for obj in parsed
        out += obj.name + " <" + obj.address + ">, "
    out
    
  fromShort: ->
    out = ""
    if @get "from"
      parsed = JSON.parse @get "from"
      for obj in parsed
        if obj.name
          out += obj.name + " "
        else
          out += obj.address + " "
    out
    
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
    
  fromAndCc: ->
    out = ""
    if @get "from"
      parsed = JSON.parse @get "from"
      for obj in parsed
        out += obj.name + " <" + obj.address + ">, "
    if @get "cc"
      parsed = JSON.parse @get "cc"
      for obj in parsed
        out += obj.name + " <" + obj.address + ">, "
    out
    
  date: ->
    parsed = new Date @get("date")
    parsed.toUTCString()
    
  subjectResponse: (mode="answer") ->
    subject = @get "subject"
    switch mode
      when "answer" then "RE: " + subject.replace(/RE:?/, "")
      when "answer_all" then "RE: " + subject.replace(/RE:?/, "")
      when "forward" then "FWD: " + subject.replace(/FWD:?/, "")
      else subject

  ccResponse: (mode="answer") ->
    switch mode
      when "answer_all" then @cc()
      else ""

  toResponse: (mode="answer") ->
    switch mode
      when "answer" then @from()
      when "answer_all" then @from()
      else ""

  text: ->
    @get("text")

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
    
  hasAttachments: ->
    @get "hasAttachments"

  htmlOrText: ->
    if @get("html")
      @html()
    else
      @text()
      
  ###
    Changing mail's properties - read and flagged
    TODO: synchronise them with remote servers.
  ###
  
  isUnread: ->
    # not("\\Seen" in JSON.parse @get("flags"))
    not @get("read")
    
  setRead: (read=true) ->
    flags = JSON.parse @get("flags")
    if read
      # set as read
      # flags
      unless "\\Seen" in flags
        flags.push("\\Seen")
        # decrement number of read messages in the mailbox
        box = window.app.mailboxes.get @get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") - 1)
      # attribute
      @set({"read" : true})
    else
      # set as unread
      # flags
      flagsPrev = flags.length
      flags = $.grep flags, (val) ->
        val != "\\Seen"
      unless flagsPrev == flags.length
        # increment the number of unread messages in the mailbox
        box = window.app.mailboxes.get @get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") + 1)
      # attribute
      @set({"read" : false})
    @set({"flags" : JSON.stringify flags})
    
  isFlagged: ->
    @get "flagged"

  setFlagged: (flagged=true) ->
    flags = JSON.parse @get("flags")
    
    if flagged
      unless "\\Flagged" in flags
        flags.push("\\Flagged")
    else
      flags = $.grep flags, (val) ->
        val != "\\Flagged"
        
    @set({"flagged" : flagged})
    @set({"flags" : JSON.stringify flags})
