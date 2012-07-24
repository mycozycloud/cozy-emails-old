{MailboxCollection} = require '../collections/mailboxes'
{MailboxesList} = require '../views/mailboxes_view'

class exports.AppView extends Backbone.View
  id: 'home-view',
  el: 'body'

  initialize: ->

  constructor: ->
    super()
    @mailboxCollection = new MailboxCollection

  render: ->
    # chargement de template par defaut
    $(@el).html require('./templates/app')
    @container_menu = @.$("#menu_container")
    @container_content = @.$("#content")


    #layout pour les mailboxes:
    @container_content.html require('./templates/layout_mailboxes')
    window.app.view_mailboxes = new MailboxesList $("#content"), @mailboxCollection
    window.app.view_mailboxes.render()
    this


# layout pour la configuration des boites mails

  set_layout_mailboxes: (view) ->
    #


  add_mailbox: (event) ->
    event.preventDefault()
    @mailboxesList.append require('./templates/add_new_mailbox')