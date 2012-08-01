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