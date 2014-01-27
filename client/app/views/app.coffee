MailListener = require 'views/mail_listener'
{MailsCollection}    = require 'collections/mails'
{MailboxCollection}  = require 'collections/mailboxes'
{MailboxesList}      = require 'views/mailboxes_list'
{MailsList}          = require 'views/mails_list'
{Menu}               = require 'views/menu'


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
            error: => alert "Error while loading mailboxes"

        @views.menu = new Menu()
        @views.menu.render().$el.appendTo $('body')

        @views.mailboxList = new MailboxesList collection: @mailboxes
        @views.mailboxList.render().$el.hide().appendTo $('body')

        @views.mailList = new MailsList collection: @mails
        @views.mailList.render().$el.hide().appendTo $('body')

        mailListener = new MailListener()
        mailListener.watch @mails
