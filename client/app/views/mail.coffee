{Mail} = require "models/mail"
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
        "click #btn-read"   : 'buttonUnread'
        "click #btn-flagged": 'buttonFlagged'
        "click #btn-delete" :  'buttonDelete'

    template: require('templates/_mail/big')
    getRenderData: -> model: @model

    initialize: ->
        console.log @model.get '_attachments'
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

                @iframe.height @iframehtml.height()

                $("#additional_bar").hide() if @iframehtml.height() > 600

            , 50

            # this timeout is a walkaround for content, which takes a while to load
            @timeout2 = setTimeout () =>
                @timeout2 = null
                @iframe = @$("#mail_content_html")
                console.log
                @iframe.height @iframehtml.height()
            , 1000

        if @model.get "hasAttachments"
            @attachmentsView?.render().$el.appendTo @$el


        @$el.niceScroll()

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
        @model.markRead not @model.isRead()
        @model.save()

    # handles flagged button
    buttonFlagged: ->
        @model.markFlagged not @model.isFlagged()
        @model.save()

    buttonDelete: ->
        @model.destroy()
