{Mail} = require "../models/mail"

###
    @file: main_router.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The application router.
        Trying to recreate the minimum of object on every reroute.
###

class exports.MainRouter extends Backbone.Router

    routes:
        '' : 'home'
        'inbox' : 'home'
        'new-mail' : 'new'
        'sent' : 'sent'
        'config-mailboxes' : 'configMailboxes'

    # routes that need regexp.
    initialize: ->
        @route(/^mail\/(.*?)$/, 'mail')

    home : ->
        app.appView.setLayoutMails()
        $(".menu_option").removeClass("active")
        $("#inboxbutton").addClass("active")

    new : ->
        app.appView.setLayoutComposeMail()
        $(".menu_option").removeClass("active")
        $("#newmailbutton").addClass("active")

    sent : ->
        app.appView.setLayoutMailsSent()
        $(".menu_option").removeClass("active")
        $("#sentbutton").addClass("active")

    configMailboxes : ->
        app.appView.setLayoutMailboxes()
        $(".menu_option").removeClass("active")
        $("#mailboxesbutton").addClass("active")
        
    mail : (path) ->
        @home()
        
        # if the mail is already downloaded, show it
        if app.mails.get(path)?
            app.mails.activeMail = app.mails.get(path)
            app.mails.trigger "change_active_mail"

        # otherwise, download it
        else
            app.mails.activeMail = new Mail id: path
            app.mails.activeMail.url = "mails/" + path
            app.mails.activeMail.fetch
                success : ->
                    app.mails.trigger "change_active_mail"
