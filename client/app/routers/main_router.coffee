{Email} = require "models/email"
{MailView} = require "views/mail"
{MailboxForm} = require "views/mailboxes_list_form"
{Mailbox} = require "models/mailbox"

class exports.MainRouter extends Backbone.Router

    routes:
        ''                          : 'rainbow'
        'rainbow'                   : 'rainbow'
        'rainbow/mail/:id'          : 'rainbowmail'
        'folder/:id'                : 'folder'
        'folder/:id/mail/:mid'      : 'foldermail'

        'config'                    : 'config'
        'config/mailboxes'          : 'config'
        'config/mailboxes/new'      : 'newMailbox'
        'config/mailboxes/:id'      : 'editMailbox'


    clear: ->
        app.views.mailboxList.activate null
        app.views.mailList.activate null
        app.views.mailList.$el.hide()
        app.views.mailboxList.$el.hide()
        app.views.mail?.remove()
        app.views.mailboxform?.remove()
        app.views.mail = null
        app.views.mailboxform = null


    rainbow : (callback) =>
        @clear()

        app.views.menu.select 'rainbow-button'
        app.views.mailboxList.$el.hide()
        app.views.mailList.$el.show()
        app.views.mailList.showLoading()

        app.mails.fetchRainbow(100).then ->
            app.views.mailList.hideLoading()
            app.views.mailList.checkIfEmpty()
            callback?()


    rainbowmail: (mailid) =>

        if app.mails.folderId is 'rainbow'
            @mail mailid
        else
            @rainbow => @mail mailid, 'rainbow'


    folder: (folderid, callback) ->
        @clear()

        app.views.menu.select 'rainbow-button'
        app.views.mailboxList.$el.hide()
        app.views.mailList.$el.show()
        app.views.mailList.showLoading()

        app.mails.fetchFolder(folderid, 100).then ->
            app.views.mailList.hideLoading()
            callback()


    foldermail: (folderid, mailid) =>
        if app.mails.folderId is folderid
            @mail mailid
        else
            @folder folderid, => @mail mailid, "folder/#{folderid}"


    mail: (id, list) ->
        if model = app.mails.get(id)
            app.views.mail?.remove()
            app.views.mail = new MailView model: model
            app.views.mail.$el.appendTo $('body')

            app.views.mail.render()

        else
            @navigate list, true

    config: ->

        @clear()

        $("#add_mailbox").removeClass 'pressed'
        app.views.menu.select 'config-button'
        app.views.mailList.$el.hide()
        app.views.mailboxList.$el.show()

    newMailbox: ->
        @config()

        $("#add_mailbox").addClass 'pressed'
        app.views.mailboxform = new MailboxForm(model: new Mailbox())
        app.views.mailboxform.$el.appendTo $('body')
        app.views.mailboxform.render()

    editMailbox: (id) ->

        unless model = app.mailboxes.get id
            return @navigate 'config/mailboxes', true

        @config()

        $("#add_mailbox").removeClass 'pressed'
        app.views.mailboxList.activate id
        app.views.mailboxform = new MailboxForm model: model
        app.views.mailboxform.$el.appendTo $('body')
        app.views.mailboxform.render()
