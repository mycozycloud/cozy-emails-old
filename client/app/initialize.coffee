###
    @file: initialize.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Building object used all over the place - collections, AppView, etc
###


{BrunchApplication} = require 'helpers'
{MainRouter} = require 'routers/main_router'
# {MailboxCollection} = require 'collections/mailboxes'
# {MailsCollection} = require 'collections/mails'
# {MailsSentCollection} = require 'collections/mails_sent'
# {AppView} = require 'views/app'
{MailsCollection}    = require 'collections/mails'
{FolderCollection}   = require 'collections/folders'
{MailboxCollection}  = require 'collections/mailboxes'
{MailboxesList}      = require 'views/mailboxes_list'
{MailsList}          = require 'views/mails_list'
{Menu}               = require 'views/menu'
{Modal}               = require 'views/modal'
SocketListener       = require 'lib/realtimer'

class exports.Application extends BrunchApplication
    # This callback would be executed on document ready event.
    # If you have a big application, perhaps it's a good idea to
    # group things by their type e.g. `@views = {}; @views.home = new HomeView`.

    initialize: ->
        @initializeJQueryExtensions()
        @mailboxes = new MailboxCollection()
        @router = new MainRouter
        @realtimer = new SocketListener()
        @views = {}

        @views.menu = new Menu()
        @views.menu.render().$el.appendTo $('body')

        @mailboxes = new MailboxCollection()
        @realtimer.watch @mailboxes
        @views.mailboxList = new MailboxesList collection: @mailboxes
        @views.mailboxList.$el.appendTo $('body')
        @views.mailboxList.render()
        @mailboxes.fetch
            # success: =>
            error: =>   alert "Error while loading mailboxes"

        @folders = new FolderCollection()
        @folders.fetch
            success: =>
                @folders.each (folder) =>
                    console.log folder
                    if folder.get('specialType') is 'ALLMAIL'
                        return @mails.fetchFolder folder.id, 100
            error: =>   alert "Error while loading folders"
        # @realtimer.watch @folder

        @mails = new MailsCollection()
        @realtimer.watch @mails
        @views.mailList = new MailsList collection: @mails
        @views.mailList.$el.appendTo $('body')
        @views.mailList.render()

        # @mails.fetchOlder
        #     # success: => @views.mailList.refresh()
        #     error: =>   alert "Error while loading mails"

        @views.modal = new Modal()
        @views.modal.render().$el.appendTo $('body')



window.app = new exports.Application
