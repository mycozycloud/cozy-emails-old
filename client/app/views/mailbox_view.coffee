{Mailbox} = require "../models/mailbox"

# Row displaying task status and description
class exports.MailboxView extends Backbone.View
  className: "mailbox_well well"
  tagName: "div"
  isEdit: false
  
  events:
    "click .edit_mailbox" : "buttonEdit"
    "click .cancel_edit_mailbox" : "buttonCancel"
    "click .save_mailbox" : "buttonSave"
    "click .delete_mailbox" : "buttonDelete"

  constructor: (@model, @collection) ->
    super()
    @model.view = @

  # enter edit mode
  buttonEdit: (event) ->
    @model.isEdit = true
    @render()
    
  # quit edit mode, no changes saved
  buttonCancel: (event) ->
    @model.isEdit = false
    @render()
    
  # save changes to server
  buttonSave: (event) ->    
    $(event.target).addClass("disabled").removeClass("buttonSave")  
    input = @.$("input.content")
    data = {}
    input.each (key, value) ->
      data[key.id] = value.value;
    @model.save data
    @collection.trigger("update_menu")
    @model.isEdit = false
    @render()
    
  # delete the mailbox
  buttonDelete: (event) =>
    $(event.target).addClass("disabled").removeClass("delete_mailbox")
    @model.destroy()

  render: ->
    # whether we should activate the edit mode or not
    if @model.isEdit
      template = require('./templates/_mailbox/mailbox_edit')
    else
      template = require('./templates/_mailbox/mailbox')
    $(@el).html template("model": @model.toJSON())
    @