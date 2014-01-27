{Email} = require "models/email"
# {MailsAnswer} = require "views/mails_answer"
{MailAttachmentsList} = require "views/mail_attachments_list"
BaseView = require 'lib/base_view'

###
    @file: mails_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The mail view. Displays all data & options.
        Also, handles buttons.

###

class exports.MailView extends BaseView

    id: 'mail'

    events:
        "click #btn-unread" : 'buttonUnread'
        "click #btn-flagged": 'buttonFlagged'
        "click #btn-delete" :  'buttonDelete'

    template: require('templates/_mail/big')
    getRenderData: -> model: @model

    initialize: ->
        @attachmentsView = new MailAttachmentsList
            model: @model

    afterRender: =>
        if @model.hasHtml()


            # this timeout is a walkaround the firefox empty iframe onLoad issue.
            @timeout1 = setTimeout () =>
                @timeout1 = null
                @iframe = @$("#mail_content_html")
                @iframehtml = @iframe.contents().find("html")

                csslink = '<link rel="stylesheet" href="css/reset_bootstrap.css">'
                basetarget = '<base target="_blank">'

                @iframehtml.html @model.html()
                @iframehtml.find('head').append csslink
                @iframehtml.find('head').append basetarget

                @resize()
            , 100

            $(window).unbind 'resize', @resize
            $(window).bind 'resize', @resize
            # this timeout is a walkaround for content, which takes a while to load
            #@timeout2 = setTimeout () =>
                #@timeout2 = null
                #@iframe = @$("#mail_content_html")
                #@iframe.height @iframehtml.height()
            #, 1000

        if @model.get "hasAttachments"
            @attachmentsView?.render().$el.appendTo @$el


    resize: =>
        panelHeight = $('.mail-panel').height()
        titleHeight = $('.mail-panel h3').height()
        infoHeight =  $('.mail-panel p:first').height()
        buttonBarHeight = $('.mail-panel .clearfix').height()

        if panelHeight < @iframehtml.height()
            $('.mail-panel').height @iframehtml.height() + titleHeight + infoHeight + buttonBarHeight + 100
            panelHeight = $('.mail-panel').height()

        if panelHeight > $(window).height()
            $('.mail-panel').height $(window).height()
            panelHeight = $('.mail-panel').height()

        @iframe.height panelHeight - titleHeight - infoHeight - buttonBarHeight - 50


    remove: =>
        @$el.getNiceScroll().remove()
        super
        clearTimeout @timeout1 if @timeout1
        clearTimeout @timeout2 if @timeout2


    ###
            CLICK ACTIONS
    ###

    createAnswerView: ->
        unless window.app.viewAnswer
            console.log "create new answer view"
            window.app.viewAnswer = new MailsAnswer @$("#answer_form"), @model, window.app.mailtosend
            window.app.viewAnswer.render()

    scrollDown: ->
        # console.log "scroll: " + $("#column_mail").outerHeight true
        # scroll down
        setTimeout () ->
            $("#column_mail").animate({scrollTop: 2 * $("#column_mail").outerHeight true}, 750)
        , 250

    # handles unread button
    buttonUnread: ->
        console.log "UNREAD"
        @model.markRead not @model.isRead()
        @model.save()

    # handles flagged button
    buttonFlagged: ->
        @model.markFlagged not @model.isFlagged()
        @model.save()

    buttonDelete: ->
        @model.destroy().then ->
            base = if app.mails.folderId is 'rainbow' then 'rainbow'
            else "folder/#{app.mails.folderId}"
            app.router.navigate base, true
