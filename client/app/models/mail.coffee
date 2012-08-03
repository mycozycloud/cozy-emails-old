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

  is_unread: ->
    not("\\Seen" in JSON.parse @get("flags"))
    
  set_read: (read=true) ->
    flags = JSON.parse @get("flags")
    if read
      flags.push("\\Seen") unless "\\Seen" in flags
    else
      flags = $.grep flags, (val) ->
        val != "\\Seen"
    @set({"flags" : JSON.stringify flags})
