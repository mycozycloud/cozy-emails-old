
###
  @file: message_box_element.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Serves a single message to user

###

class exports.MessageBoxElement extends Backbone.View

  constructor: (@model, @collection) ->
    super()
    @model.view = @
    
  events:
    "click button.close" : 'buttonClose'
    
  buttonClose: =>
    if @model.get("timeout") == 0
       @model.destroy()
       @remove()
    
  remove: =>
    $(@el).remove()

  render: ->
    if @model.get("timeout") != 0
       setTimeout @remove, @model.get("timeout") * 1000
    
    type = @model.get("type")
    
    if type == "error"
        template = require('./templates/_message/message_error')
    else if type == "success"
        template = require('./templates/_message/message_success')
    else if type == "warning"
        template = require('./templates/_message/message_warning')
    else
        template = require('./templates/_message/message_info')
        
    $(@el).html template('model': @model)
    @
