{BrunchApplication} = require 'helpers'
{MainRouter} = require 'routers/main_router'
{MailboxCollection} = require 'collections/mailboxes'
{MailsCollection} = require 'collections/mails'
{AppView} = require 'views/app'

class exports.Application extends BrunchApplication
  # This callback would be executed on document ready event.
  # If you have a big application, perhaps it's a good idea to
  # group things by their type e.g. `@views = {}; @views.home = new HomeView`.
  initialize: ->
    @mailboxes = new MailboxCollection
    @mails = new MailsCollection
    @router = new MainRouter
    @appView = new AppView

window.app = new exports.Application