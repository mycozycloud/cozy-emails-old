BaseModel = require("./models").BaseModel

# Defines a mailbox
class exports.Mail extends BaseModel
  # 
  # defaults:
  #   'title' : "hello"
  #   'date' : "yesterday"
  #   'from' : "example@domain.com"

  initialize: ->
    @on "destroy", @removeView, @
    @on "change",  @redrawView, @

  removeView: ->
    @view.remove() if @view?

  redrawView: ->
    @view.render() if @view?