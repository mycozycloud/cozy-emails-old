{Mailbox} = require "../models/mailbox"

###
    @file: mailboxes_list_new.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The toolbar to add a new mailbox.
        mailboxes_list -> mailboxes_list_new

###

class exports.MailboxesListNew extends Backbone.View

    id: "add_mail_button_container"
    el: "#add_mail_button_container"

    events:
         "click #add_mailbox" : 'addMailbox',

    constructor: (@collection) ->
        super()

    addMailbox: (event) ->
        event.preventDefault()
        newbox = new Mailbox()
        newbox.isEdit = true
        @$("#add_mailbox").hide()
        @collection.add newbox

    render: ->
        @$el.html require('./templates/_mailbox/mailbox_new')
        @
