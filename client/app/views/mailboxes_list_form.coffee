BaseView = require 'lib/base_view'
class exports.MailboxForm extends BaseView

    id: "mailbox-form"
    template: require 'templates/_mailbox/form'

    events:
        "click .cancel_edit_mailbox": "buttonCancel"
        "click .save_mailbox": "buttonSave"
        "click .delete-mailbox": "onDeleteClicked"

    initialize: ->
        super
        @listenTo @model, 'destroy', @buttonCancel

    getRenderData: -> model: @model

    afterRender: ->
        @$el.niceScroll()

    # quit edit mode, no changes saved
    buttonCancel: (event) ->
        app.router.navigate 'config/mailboxes', true

    # save changes to server
    buttonSave: (event) ->
        if $(event.target).hasClass("disabled") then return false

        $(event.target).addClass("disabled").removeClass("buttonSave")
        input = @$(".content")
        data =
            name: @$('#name').val()
            color: @$('#color').val()

        input.each (i) ->
            data[input[i].id] = input[i].value
        @model.isEdit = false
        @model.save data,
            success: =>
                $("#add_mailbox").show()
                $("#no-mailbox-msg").hide()

                window.app.views.mailList.updateColors()
                @render()
            error: (model, xhr) ->
                msg = "Server error occured"
                if xhr.status is 400
                    data = JSON.parse xhr.responseText
                    msg = data.error

                alert msg
                $(event.target).removeClass("disabled").addClass("buttonSave")

        app.router.navigate 'config/mailboxes', true

    onDeleteClicked: (event) =>
        app.views.modal.showAndThen (callback) =>
            $(event.target).addClass("disabled")
            @model.destroy
                error: (model, xhr) ->
                    msg = "Server error occured"
                    if xhr.status is 400
                        data = JSON.parse xhr.responseText
                        msg = data.error

                    alert msg
                    $(event.target).removeClass("disabled")
