{MailboxesList} = require '../views/mailboxes_list'
{MailboxesListNew} = require '../views/mailboxes_list_new'
{MenuMailboxesList} = require '../views/menu_mailboxes_list'
{MailsColumn} = require '../views/mails_column'
{MailsElement} = require '../views/mails_element'

###

  The application's main view - creates other views, lays things out.

###
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
    
###################################################
## COMMON
###################################################
        
  # layout the dynamic menu
  set_layout_menu: ->
    @container_menu.html require('./templates/menu')
    window.app.view_menu = new MenuMailboxesList @.$("#menu_mailboxes"), window.app.mailboxes
    window.app.view_menu.render()

###################################################
## LAYOUTS
###################################################

  # put on the layout to display mailboxes:
  set_layout_mailboxes: ->
    # lay the mailboxes out
    @container_content.html require('./templates/_layouts/layout_mailboxes')
    window.app.view_mailboxes = new MailboxesList @.$("#mail_list_container"), window.app.mailboxes
    window.app.view_mailboxes_new = new MailboxesListNew @.$("#add_mail_button_container"), window.app.mailboxes
    window.app.view_mailboxes.render()
    window.app.view_mailboxes_new.render()
    

  # put on the layout to display mails:
  set_layout_mails: ->
    # lay the mailboxes out
    @container_content.html require('./templates/_layouts/layout_mails')
    # create views for the columns
    window.app.view_mails_list = new MailsColumn @.$("#column_mails_list"), window.app.mails
    window.app.view_mail = new MailsElement @.$("#column_mail"), window.app.mails
    window.app.view_mails_list.render()
    
  # set the layout for coulmn view - mails
  set_layout_cols: ->
    @container_content.html require('./templates/_mail/mails')