BaseModel = require("./models").BaseModel

###

  Model which defines the MAIL object.

###
class exports.Mail extends BaseModel

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @

  removeView: ->
    @view.remove() if @view?

  redrawView: ->
    @view.render() if @view?

  ###
      RENDERING
  ###

  from: ->
    parsed = JSON.parse(@get("from"))
    out = ""
    for obj in parsed
      out += obj.name + " <" + obj.address + "> "
    out
    
  from_short: ->
    parsed = JSON.parse(@get("from"))
    out = ""
    for obj in parsed
      if obj.name
        out += obj.name + " "
      else
        out += obj.address + " "
    out
    
  cc: ->
    parsed = JSON.parse(@get("cc"))
    out = ""
    for obj in parsed
      out += obj.name + " <" + obj.address + "> "
    out

  cc_short: ->
    parsed = JSON.parse(@get("cc"))
    out = ""
    for obj in parsed
      out += obj.name + " "
    out
    
  date: ->
    parsed = new Date @get("date")
    parsed.toUTCString()

  text: ->
    @get("text").replace(/\r\n/g,'\n').replace(/\n/g, '<br />')

  html: ->
    expression = new RegExp("(<style>(.|\s)*?</style>)", "gi");
    exp = ///
      /(<style>(.|\s)*?</style>)/ig
      ///
    string = new String @get("html")
    string.replace(expression,"")
  
  text_or_html: ->
    if @get("html")
      @html()
    else
      @text()
  
  is_unread: ->
    # not("\\Seen" in JSON.parse @get("flags"))
    not @get("read")
    
  set_read: (read=true) ->
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
      flags_prev = flags.length
      flags = $.grep flags, (val) ->
        val != "\\Seen"
      unless flags_prev == flags.length
        # increment the number of unread messages in the mailbox
        box = window.app.mailboxes.get @get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") + 1)
      # attribute
      @set({"read" : false})
    @set({"flags" : JSON.stringify flags})
    
  is_flagged: ->
    @get "flagged"

  set_flagged: (flagged=true) ->
    flags = JSON.parse @get("flags")
    
    if flagged
      unless "\\Flagged" in flags
        flags.push("\\Flagged")
    else
      flags_prev = flags.length
      flags = $.grep flags, (val) ->
        val != "\\Flagged"
        
    @set({"flagged" : flagged})
    @set({"flags" : JSON.stringify flags})
