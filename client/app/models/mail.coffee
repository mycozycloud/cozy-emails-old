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
    @prerender()
    @view.render() if @view?
  
###
    PRERENDERING
###

  _render_from: (from) ->
    parsed = JSON.parse(from)
    out = ""
    for addr, name in parsed
      out + name + ", "
    out