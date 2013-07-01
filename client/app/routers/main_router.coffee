{Mail} = require "models/mail"
{MailView} = require "views/mail"
{MailboxForm} = require "views/mailboxes_list_form"
{Mailbox} = require "models/mailbox"

###
    @file: main_router.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The application router.
        Trying to recreate the minimum of object on every reroute.
###

class exports.MainRouter extends Backbone.Router

    routes:
        ''                          : 'rainbow'
        'rainbow'                   : 'rainbow'
        'folder/:id'                : 'folder'
        'mail/:id'                  : 'mail'
        # 'new-mail'         : 'new'
        # 'sent'             : 'sent'
        'config'                    : 'config'
        'config/mailboxes'          : 'config'
        'config/mailboxes/new'      : 'newMailbox'
        'config/mailboxes/:id'      : 'editMailbox'

    clear: ->
        console.log "clear"
        app.views.mailboxList.activate null
        app.views.mailList.activate null
        app.views.mailList.$el.hide()
        app.views.mailboxList.$el.hide()
        app.views.mail?.remove()
        app.views.mailboxform?.remove()
        app.views.mail = null
        app.views.mailboxform = null

    rainbow : =>
        console.log "rainbow"

        @clear()


        if app.mails.length is 0
            app.mails.once 'sync', @rainbow


        app.mails.fetchRainbow 100
        app.views.menu.select 'inboxbutton'
        app.views.mailboxList.$el.hide()
        app.views.mailList.$el.show()

    folder: (folderid) ->

        @rainbow()

        app.mails.fetchFolder folderid, 100

    config : ->
        console.log "config"

        @clear()

        app.views.menu.select 'mailboxesbutton'
        app.views.mailList.$el.hide()
        app.views.mailboxList.$el.show()

    newMailbox: ->
        @config()

        app.views.mailboxform = new MailboxForm(model: new Mailbox())
        app.views.mailboxform.$el.appendTo $('body')
        app.views.mailboxform.render()

    editMailbox: (id) ->

        unless model = app.mailboxes.get id
            return @navigate 'config/mailboxes', true

        @config()

        app.views.mailboxList.activate id
        app.views.mailboxform = new MailboxForm model: model
        app.views.mailboxform.$el.appendTo $('body')
        app.views.mailboxform.render()


    mail : (id) ->

        console.log "mail"

        # wait for maillist to load
        if app.mails.length is 0
            return app.mails.on 'sync', => @mail id

        app.views.menu.select 'inboxbutton'

        app.views.mailboxList.$el.hide()
        app.views.mailList.activate id
        app.views.mailList.$el.show()

        app.views.mail?.remove()

        # if the mail is already downloaded, show it
        if model = app.mails.get(id)
            app.views.mail = new MailView model: model
            app.views.mail.$el.appendTo $('body')
            app.views.mail.render()

        else
            model = new Mail(id: id)
            model.fetch
                success: -> app.views.mail.render()
            app.views.mail = new MailView model: model
            app.views.mail.$el.appendTo $('body')
            app.views.mail.render()
