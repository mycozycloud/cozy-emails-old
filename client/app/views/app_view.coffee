{MailboxesList} = require '../views/mailboxes_view'
{MailboxesMenuList} = require '../views/mailboxes_menu_view'

class exports.AppView extends Backbone.View
  id: 'home-view',
  el: 'body'

  initialize: ->
    window.app.mailboxes.fetch()
    
  constructor: ->
    super()

  render: ->
    # put on the big layout
    $(@el).html require('./templates/app')
    @container_menu = @.$("#menu_container")
    @container_content = @.$("#content")
    @set_layout_menu()
    @
        
  # layout pour la configuration des boites mails
  set_layout_menu: ->
    @container_menu.html require('./templates/menu')
    window.app.view_menu = new MailboxesMenuList $("#menu_mailboxes"), window.app.mailboxes
    window.app.view_menu.render()

###################################################
## LAYOUTS
###################################################

  # put on the layout to display mailboxes:
  set_layout_mailboxes: ->
    # lay the mailboxes out
    @container_content.html require('./templates/_layouts/layout_mailboxes')
    window.app.view_mailboxes = new MailboxesList $("#content"), window.app.mailboxes
    window.app.view_mailboxes.render()
    
  # set the layout for coulmn view - mails
  set_layout_cols: ->
    @container_content.html require('./templates/_mail/mails')