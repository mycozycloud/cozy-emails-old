{MailboxesList} = require '../views/mailboxes_list'
{MailboxesListNew} = require '../views/mailboxes_list_new'
{MenuMailboxesList} = require '../views/menu_mailboxes_list'
{MailsColumn} = require '../views/mails_column'
{MailsSentColumn} = require '../views/mailssent_column'
{MailsElement} = require '../views/mails_element'
{MailsSentElement} = require '../views/mailssent_element'
{MailsCompose} = require '../views/mails_compose'
{MessageBox} = require 'views/message_box'
{LogMessagesCollection} = require 'collections/logmessages'
{MailboxCollection} = require 'collections/mailboxes'

###
    @file: app.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The application's main view - creates other views, lays things out.

###

class exports.AppView extends Backbone.View

    el: 'body'

    initialize: ->
        # capture the resize event, to adjust the size of UI
        window.onresize = @resize
        
        # put on the big layout
        @$el.html require('./templates/app')
        @containerMenu = @$("#menu_container")
        @containerContent = @$("#content")
        @viewMessageBox =
            new MessageBox @$("#message_box"), new LogMessagesCollection
        @setLayoutMenu()
    
    # making sure the view takes 100% height of the viewport.
    resize: ->
        viewport = ->
            e = window
            a = "inner"
            unless "innerWidth" of window
                a = "client"
                e = document.documentElement or document.body
            e[a + "Height"]
        $("body").height viewport() - 10
        $("#content").height viewport() - 10
        $(".column").height viewport() - 10

        
###################################################
## COMMON
###################################################
                
    # layout the dynamic menu
    setLayoutMenu: (callback) ->
        
        # set ut the menu view
        @containerMenu.html require('./templates/menu')
        @mailboxMenu =
            new MenuMailboxesList $("#menu_mailboxes"), new MailboxCollection
        
        @mailboxes = @mailboxMenu.collection

        # fetch necessary data
        @mailboxMenu.render()
        @mailboxes.reset()
        @mailboxMenu.showLoading()
        @mailboxes.fetch
            success: =>
                @mailboxes.updateActiveMailboxes()
                @mailboxes.trigger "change_active_mailboxes"
                callback() if callback?
            error: =>
                @$("#menu_mailboxes").html ""
            

###################################################
## LAYOUTS
###################################################

    # put on the layout to display mailboxes:
    setLayoutMailboxes: ->
        
        # lay the mailboxes out
        @containerContent.html require('./templates/_layouts/layout_mailboxes')

        @mailboxesView =
            new MailboxesList @$("#mail_list_container"), @mailboxes
        @newMailboxesView =
            new MailboxesListNew @$("#add_mail_button_container"), @mailboxes
        
        @setLayoutMenu =>
            @newMailboxesView.render()
        
        @mailboxesView.render()

        # ensure the right size
        @resize()


    # put on the layout to display mailboxes:
    setLayoutComposeMail: ->

        # lay the mailboxes out
        @containerContent.html require('./templates/_layouts/layout_compose_mail')
        window.app.viewComposeMail =
            new MailsCompose @$("#compose_mail_container"), @mailboxes
        
        @setLayoutMenu ->
            window.app.viewComposeMail.render()

        # ensure the right size
        @resize()

    # Depending on mail number it displays the mail list or an informative
    # message explaining why the mail list is empty and what to do to fill it.
    showMailList: ->
        if window.app.mails.length is 0
            @$("#more-button").hide()
            @$("#button_get_new_mails").hide()
            @$("#no-mails-message").show()
        else
            @$("#no-mails-message").hide()

    # put on the layout to display mails:
    setLayoutMails: ->
        # lay the mails out
        @containerContent.html require('./templates/_layouts/layout_mails')
        
        # create views for the columns
        window.app.viewMailsList =
            new MailsColumn @$("#column_mails_list"), window.app.mails, @mailboxes
        window.app.viewMailsList.render()
        window.app.view_mail =
            new MailsElement @$("#column_mail"), window.app.mails
        
        @$("#no-mails-message").hide()

        # fetch necessary data
        if @mailboxes.length is 0
            @mailboxes.fetch
                success: =>
                    if window.app.mails.length is 0
                        # fetch necessary data
                        @$("#column_mails_list tbody").prepend "<span>loading...</span>"
                        @$("#column_mails_list tbody").spin "small"
                        window.app.mails.fetchOlder =>
                            @$("#column_mails_list tbody").spin()
                            @$("#column_mails_list tbody span").remove()
                            @mailboxes.updateActiveMailboxes()
                            @showMailList()
                        , =>
                            @$("#column_mails_list tbody").spin()
                            @$("#column_mails_list tbody span").remove()
                            @showMailList()

                
        else if window.app.mails.length is 0
            # fetch necessary data
            @$("#column_mails_list tbody").prepend "<span>loading...</span>"
            @$("#column_mails_list tbody").spin "small"
            window.app.mails.fetchOlder () =>
                @$("#column_mails_list tbody").spin()
                @$("#column_mails_list tbody span").remove()
                @mailboxes.updateActiveMailboxes()
                @showMailList()
        else
            @$("#no-mails-message").hide()
        
        # ensure the right size
        @resize()
        
    # put on the layout to display mails:
    setLayoutMailsSent: ->

        # lay the mails out
        @containerContent.html require('./templates/_layouts/layout_mails')

        # create views for the columns
        window.app.viewMailsSentList = new MailsSentColumn @$("#column_mails_list"), window.app.mailssent
        window.app.viewMailsSentList.render()
        window.app.view_mailsent = new MailsSentElement @$("#column_mail"), window.app.mailssent

        # fetch necessary data
        if @mailboxes.length is 0
            @mailboxes.fetch
                success: ->
                    console.log "Initial mails sent mailboxes load OK"
                    if window.app.mailssent.length is 0
                        # fetch necessary data
                        window.app.mailssent.fetchOlder ->
                                console.log "Initial mails sent mails load OK"
                                window.app.mailboxes.updateActiveMailboxes()
        else if window.app.mailssent.length is 0
            # fetch necessary data
            window.app.mailssent.fetchOlder ->
                console.log "Initial mails sent mails load OK"
                @mailboxes.updateActiveMailboxes()

        # ensure the right size
        @resize()
