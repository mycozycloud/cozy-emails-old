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
