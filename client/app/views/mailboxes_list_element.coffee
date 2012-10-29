{Mailbox} = require "../models/mailbox"

###
  @file: mailboxes_list_element.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The element of the list of mailboxes.
    mailboxes_list -> mailboxes_list_element

###

class exports.MailboxesListElement extends Backbone.View
  
  className: "mailbox_well well"
  isEdit: false
  
  events:
    "click .edit_mailbox" : "buttonEdit"
    "click .cancel_edit_mailbox" : "buttonCancel"
    "click .save_mailbox" : "buttonSave"
    "click .delete_mailbox" : "buttonDelete"
    "input input#name" : "updateName"
    "change #color" : "updateColor"
    
    "click .fetch_mailbox" : "buttonFetchMailbox"
    "click .fetch_mails" : "buttonFetchMails"

  constructor: (@model, @collection) ->
    super()
    @model.view = @
    
  initialize: ->
    view = @
    model = @model
    
  # updates the name of the mailbox
  updateName: (event) ->
    @model.set "name", $(event.target).val()

  # updates the color of the mailbox
  updateColor: (event) ->
    @model.set "color", $(event.target).val()
    
  # download new mail
  buttonFetchMails: (event) ->
    $(event.target).addClass("disabled").removeClass("fetch_mails").text("Loading...")
    $.ajax "fetchmailbox/" + @model.id, {
      complete: () ->
        window.app.mails.fetchNew()
        $(event.target).removeClass("disabled").addClass("fetch_mails").text("Check for new mail complete")
    }
    
  # fetch mailbox
  buttonFetchMailbox: (event) ->
    view = @
    $(event.target).addClass("disabled").removeClass("fetch_mailbox").text("Loading...")
    @model.url = 'mailboxes/' + @model.id
    @model.fetch {
      success: ->
        $(event.target).removeClass("disabled").addClass("fetch_mailbox").text("Status verified")
        view.render()
    }

  # enter edit mode
  buttonEdit: (event) ->
    @model.isEdit = true
    @render()
    
  # quit edit mode, no changes saved
  buttonCancel: (event) ->
    if @model.isNew()
      @model.destroy()
    @model.isEdit = false
    @render()
    
  # save changes to server
  buttonSave: (event) ->    
    $(event.target).addClass("disabled").removeClass("buttonSave")  
    input = @.$(".content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value
    @model.isEdit = false
    if @model.isNew()
      @model.save data, {
        success: (modelSaved, response) =>
          $.ajax "importmailbox/" + modelSaved.id, {
            complete: () ->
              console.log "importmailbox/" + modelSaved.id
          }
          @render()
      }
    else
      @model.save data, {
        success: () =>
          @render()
      }
    
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
    $(@el).html template("model": @model)
    @