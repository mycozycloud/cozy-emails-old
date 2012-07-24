{MailboxesList} = require '../views/mailboxes_view'
{MailboxesMenuList} = require '../views/mailboxes_menu_view'

class exports.AppView extends Backbone.View
  id: 'home-view',
  el: 'body'

  initialize: ->

  constructor: ->
    super()

  render: ->
    # chargement de template par defaut
    $(@el).html require('./templates/app')
    @container_menu = @.$("#menu_container")
    @container_content = @.$("#content")
    @set_layout_menu()
    @
    
    
  set_layout_menu: ->
    #layout pour les mailboxes:
    @container_menu.html require('./templates/menu')
    window.app.view_menu = new MailboxesMenuList $("#menu_mailboxes"), window.app.mailboxes
    window.app.view_menu.render()

# layout pour la configuration des boites mails

  set_layout_mailboxes: ->
    #layout pour les mailboxes:
    @container_content.html require('./templates/layout_mailboxes')
    window.app.view_mailboxes = new MailboxesList $("#content"), window.app.mailboxes
    window.app.view_mailboxes.render()
    
  set_layout_cols: ->
    #layout pour les mails
    @container_content.html require('./templates/mails_view')


  add_mailbox: (event) ->
    event.preventDefault()
    @mailboxesList.append require('./templates/add_new_mailbox')