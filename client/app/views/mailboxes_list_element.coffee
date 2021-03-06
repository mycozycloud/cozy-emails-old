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
        "click": "buttonEdit"

    initialize: () ->
        super
        @listenTo @model, 'change', @render

    # enter edit mode
    buttonEdit: (event) =>
        app.router.navigate "config/mailboxes/#{@model.id}", true
