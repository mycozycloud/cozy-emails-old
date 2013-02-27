{Mail} = require "../models/mail"

{MailsList} = require "../views/mails_list"
{MailsListMore} = require "../views/mails_list_more"
{MailsListNew} = require "../views/mails_list_new"

###
    @file: mails_column.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The view of the central column - the one which holds the list of mail.
    
###

class exports.MailsColumn extends Backbone.View
    id: "mailslist"
    className: "mails"

    constructor: (@el, @collection, @mailboxes) ->
        super()

    render: ->
        @$el.html require('./templates/_mail/mails')
        # the button to check for new mail
        @viewMailsListNew =
            new MailsListNew @$("#button_get_new_mails"), @collection
        # thea actual list of mails
        @viewMailsList =
            new MailsList @$("#mails_list_container"), @collection
        # the button to load older mail
        el = @$("#button_load_more_mails")
        @viewMailsListMore =
            new MailsListMore el, @collection, @mailboxes

        @viewMailsListNew.render()
        @viewMailsList.render()
        @viewMailsListMore.render()
        @
