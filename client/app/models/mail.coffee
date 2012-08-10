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
      out += obj.name + " "
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
   
  is_unread: ->
    not("\\Seen" in JSON.parse @get("flags"))
    
  set_read: (read=true) ->
    flags = JSON.parse @get("flags")
    if read
      # set as read
      unless "\\Seen" in flags
        flags.push("\\Seen")
        # decrement number of read messages in the mailbox
        box = window.app.mailboxes.get @get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") - 1)
    else
      # set as unread
      flags_prev = flags.length
      flags = $.grep flags, (val) ->
        val != "\\Seen"
      unless glasgs_prev == flags.length
        # increment the number of unread messages in the mailbox
        box = window.app.mailboxes.get @get("mailbox")
        box?.set "new_messages", ((parseInt box?.get "new_messages") + 1)
    @set({"flags" : JSON.stringify flags})
