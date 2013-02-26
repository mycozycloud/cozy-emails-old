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

    constructor: (@model, @collection) ->
        super()
        @model.view = @
        
    # updates the name of the mailbox
    updateName: (event) ->
        @model.set "name", $(event.target).val()

    # updates the color of the mailbox
    updateColor: (event) ->
        @model.set "color", $(event.target).val()
        
    # enter edit mode
    buttonEdit: (event) ->
        @model.isEdit = true
        @render()
        
    # quit edit mode, no changes saved
    buttonCancel: (event) ->
        @model.isEdit = false
        @model.destroy() if @model.isNew()
        @render()
        
    # save changes to server
    buttonSave: (event) ->
        $(event.target).addClass("disabled").removeClass("buttonSave")
        input = @$(".content")
        data = {}
        input.each (i) ->
            data[input[i].id] = input[i].value
        @model.isEdit = false
        @model.save data, success: @render
        
    buttonDelete: (event) =>
        $(event.target).addClass("disabled").removeClass("delete_mailbox")
        @model.destroy()

    render: ->
        # whether we should activate the edit mode or not
        if @model.isEdit
            template = require('./templates/_mailbox/mailbox_edit')
        else
            template = require('./templates/_mailbox/mailbox')
        @$el.html template(model: @model)
        @
