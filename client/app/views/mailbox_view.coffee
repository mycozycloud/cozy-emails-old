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
    "click .edit_mailbox" : "buttonEdit"
    "click .cancel_edit_mailbox" : "buttonCancel"
    "click .save_mailbox" : "buttonSave"
    "click .delete_mailbox" : "buttonDelete"
  
  # enter edit mode
  buttonEdit: (event) ->
    # console.log event
    @model.isEdit = true
    @render()
    
    # enter edit mode
  buttonCancel: (event) ->
    # console.log event
    @model.isEdit = false
    @render()
    
  # save changes to server
  buttonSave: (event) ->    
    input = @.$("input.content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value;
    @model.save data
    @collection.trigger("update_menu")
    @model.isEdit = false
    @render()
    
  # delete the mailbox
  buttonDelete: (event) ->
    console.log @
    $(".delete_mailbox").addClass("disabled")
    @model.destroy
      success: ->
        @remove()
      error: ->
        alert "error"
        @remove()

  # Render wiew and bind it to model.
  render: ->
    # whether we should activate the edit mode or not
    if @model.isEdit
      template = require('./templates/mailbox_edit')
    else
      template = require('./templates/mailbox')
    $(@el).html template("model": @model.toJSON())
    @