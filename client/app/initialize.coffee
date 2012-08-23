{BrunchApplication} = require 'helpers'
{MainRouter} = require 'routers/main_router'
{MailboxCollection} = require 'collections/mailboxes'
{MailsCollection} = require 'collections/mails'
{AttachmentsCollection} = require "collections/attachments"
{AppView} = require 'views/app'
{MailNew} = require 'models/mail_new'

class exports.Application extends BrunchApplication
  # This callback would be executed on document ready event.
  # If you have a big application, perhaps it's a good idea to
  # group things by their type e.g. `@views = {}; @views.home = new HomeView`.
  
  initialize: ->
    @mailboxes = new MailboxCollection
    @mails = new MailsCollection
    @router = new MainRouter
    @appView = new AppView
    @mailtosend = new MailNew
    @attachments = new AttachmentsCollection

window.app = new exports.Application