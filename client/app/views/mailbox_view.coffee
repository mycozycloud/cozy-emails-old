{Mailbox} = require "../models/mailbox"

# Row displaying task status and description
class exports.MailboxView extends Backbone.View
  className: "mailbox_well well"
  tagName: "div"
  isEdit: false
  
  constructor: (@model, @collection) ->
    super()
  
  # EVENTS
  events:
    "click .edit_mailbox" : "edit"
    "click .save_mailbox" : "save"
    "click .delete_mailbox" : "delete"
    
  
  # enter edit mode
  edit: (event) ->
    # console.log event
    @isEdit = true
    @render()
    
  # save changes to server
  save: (event) ->    
    input = @.$("input.content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value;
    @model.save data
    @isEdit = false
    @render()
    
  # delete the mailbox
  delete: (event) ->
    console.log @
    @collection.removeOne @model, @

  # Render wiew and bind it to model.
  render: ->
    # whether we should activate the edit mode or not
    if @isEdit
      template = require('./templates/mailbox_edit')
      $(@el).html template("model": @model.toJSON())
      @.$(".isntEdit").hide()
      @.$(".isEdit").show()
    else
      template = require('./templates/mailbox')
      $(@el).html template("model": @model.toJSON())
      @.$(".isntEdit").show()
      @.$(".isEdit").hide()
    @