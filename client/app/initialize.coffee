###
    @file: initialize.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Building object used all over the place - collections, AppView, etc
###


{BrunchApplication} = require 'helpers'
{MainRouter} = require 'routers/main_router'
{MailboxCollection} = require 'collections/mailboxes'
{MailsCollection} = require 'collections/mails'
{MailsSentCollection} = require 'collections/mails_sent'
{AppView} = require 'views/app'
{MailNew} = require 'models/mail_new'

class exports.Application extends BrunchApplication
    # This callback would be executed on document ready event.
    # If you have a big application, perhaps it's a good idea to
    # group things by their type e.g. `@views = {}; @views.home = new HomeView`.
    
    initialize: ->
        @initializeJQueryExtensions()
        @mails = new MailsCollection
        @mailssent = new MailsSentCollection
        @router = new MainRouter
        @appView = new AppView
        @mailtosend = new MailNew
        

window.app = new exports.Application
