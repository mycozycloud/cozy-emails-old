###
    @file: mailboxes_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The element of the list of mailboxes.
        mailboxes_list -> mailboxes_list_element

###
BaseView = require 'lib/base_view'

module.exports = class MailboxesListElement extends BaseView

    className: "mailbox_well well"
    template: require('templates/_mailbox/thumb')
    isEdit: false

    events:
        "click .edit-mailbox"        : "buttonEdit"
        "click .delete-mailbox"      : "buttonDelete"

    initialize: () ->
        super
        @listenTo @model, 'change', @render

    # enter edit mode
    buttonEdit: (event) =>
        app.router.navigate "config/mailboxes/#{@model.id}", true

    buttonDelete: (event) =>
        app.views.modal.showAndThen =>
            $(event.target).addClass("disabled")
            @model.destroy
                error: (model, xhr) ->
                    msg = "Server error occured"
                    if xhr.status is 400
                        data = JSON.parse xhr.responseText
                        msg = data.error

                    alert msg
                    $(event.target).removeClass("disabled")
