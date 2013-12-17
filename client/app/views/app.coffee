{MailsCollection}    = require 'collections/mails'
{MailboxCollection}  = require 'collections/mailboxes'
{MailboxesList}      = require 'views/mailboxes_list'
{MailsList}          = require 'views/mails_list'
{Menu}               = require 'views/menu'

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
        # window.onresize = @resize

        @views = {}



        @mails = new MailsCollection()
        @mailboxes = new MailboxCollection()
        @mailboxes.fetch
            success: => @views.mailboxList.render()
            error: =>   alert "Error while loading mailboxes"

        @views.menu = new Menu()
        @views.menu.render().$el.appendTo $('body')


        @views.mailboxList = new MailboxesList collection: @mailboxes
        @views.mailboxList.render().$el.hide().appendTo $('body')

        @views.mailList = new MailsList collection: @mails
        @views.mailList.render().$el.hide().appendTo $('body')




        # put on the big layout
        # @$el.html require('templates/app')
        # @containerMenu = @$("#menu_container")
        # @containerContent = @$("#content")
        # @boxContainerContent = @$("#box-content")
        # @mailboxes = new MailboxCollection
        # @setLayoutMenu()

    # # making sure the view takes 100% height of the viewport.
    # resize: ->
    #     viewport = (window['innerHeight'] or
    #                 document.documentElement['clientHeight'] or
    #                 document.body['clientHeight'])

    #     $("body").height viewport
    #     $("#content").height viewport
    #     $("#box-content").height viewport
    #     $("#box-content").css 'overflow', 'auto'
    #     $(".column").height viewport
    #     $("#sidebar").height viewport


    # layout the dynamic menu
    # setLayoutMenu: (callback) ->

    #     # set ut the menu view
    #     @containerMenu.html require('templates/menu')


    # # put on the layout to display mailboxes:
    # setLayoutMailboxes: ->

    #     if @boxContainerContent.html() is ""
    #         @boxContainerContent.html require('templates/_layouts/layout_mailboxes')

    #         @mailboxesView =
    #             new MailboxesList collection: @mailboxes
    #         @newMailboxesView =
    #             new MailboxesListNew collection: @mailboxes

    #         @mailboxes.reset()
    #         @mailboxes.fetch
    #             success: =>
    #                 @newMailboxesView.render()
    #             error: =>
    #                 alert "Error while loading mailboxes"
    #         @mailboxesView.render()

    #     @containerContent.hide()
    #     @boxContainerContent.show()

    #     @resize()

    # setLayoutMails: ->
    #     @boxContainerContent.hide()
    #     @containerContent.show()
    #     renderScroll = false
    #     if @containerContent.html() is ""
    #         @containerContent.html require('templates/_layouts/layout_mails')

    #         window.app.viewMailsList =
    #             new MailsColumn @$("#column_mails_list"), window.app.mails, @mailboxes
    #         window.app.viewMailsList.render()
    #         window.app.view_mail =
    #             new MailsElement @$("#column_mail"), window.app.mails

    #         renderScroll = true

    #     @$("#no-mails-message").hide()
    #     if @mailboxes.length is 0
    #         @mailboxes.fetch
    #             success: =>
    #                 if window.app.mails.length is 0
    #                     @$("#column_mails_list tbody").prepend "<span>loading...</span>"
    #                     @$("#column_mails_list tbody").spin "small"
    #                     window.app.mails.fetchOlder =>
    #                         @$("#column_mails_list tbody").spin()
    #                         @$("#column_mails_list tbody span").remove()
    #                         @mailboxes.updateActiveMailboxes()
    #                         @showMailList()
    #                         if renderScroll
    #                             @$("#column_mails_list").niceScroll
    #                                 cursorcolor: "#CCC"
    #                         window.app.mails.fetchNew()
    #                     , =>
    #                         @$("#column_mails_list tbody").spin()
    #                         @$("#column_mails_list tbody span").remove()
    #                         @showMailList()
    #                         if renderScroll
    #                             @$("#column_mails_list").niceScroll
    #                                 cursorcolor: "#CCC"


    #     else if window.app.mails.length is 0
    #         # fetch necessary data
    #         @$("#column_mails_list tbody").prepend "<span>loading...</span>"
    #         @$("#column_mails_list tbody").spin "small"
    #         window.app.mails.fetchOlder () =>
    #             @$("#column_mails_list tbody").spin()
    #             @$("#column_mails_list tbody span").remove()
    #             @mailboxes.updateActiveMailboxes()
    #             @showMailList()
    #             if renderScroll
    #                 @$("#column_mails_list").niceScroll
    #                     cursorcolor: "#CCC"
    #     else
    #         @$("#no-mails-message").hide()
    #         if renderScroll
    #             @$("#column_mails_list").niceScroll
    #                 cursorcolor: "#CCC"

    #     # ensure the right size
    #     @resize()

    # # Depending on mail number it displays the mail list or an informative
    # # message explaining why the mail list is empty and what to do to fill it.
    # showMailList: ->
    #     if window.app.mails.length is 0
    #         @$("#more-button").hide()
    #         @$("#button_get_new_mails").hide()
    #         @$("#no-mails-message").show()
    #     else
    #         @$("#no-mails-message").hide()
