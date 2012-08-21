{MailboxesList} = require '../views/mailboxes_list'
{MailboxesListNew} = require '../views/mailboxes_list_new'
{MenuMailboxesList} = require '../views/menu_mailboxes_list'
{MailsColumn} = require '../views/mails_column'
{MailsElement} = require '../views/mails_element'
{MailsCompose} = require '../views/mails_compose'
{MessageBox} = require 'views/message_box'
###

  The application's main view - creates other views, lays things out.

###
class exports.AppView extends Backbone.View

  el: 'body'

  initialize: ->
    # capture the resize event, to adjust the size of UI
    window.onresize = @resize
    
    # put on the big layout
    $(@el).html require('./templates/app')
    @container_menu = @.$("#menu_container")
    @container_content = @.$("#content")
    @message_box_view = new MessageBox @.$("#message_box"), window.app.mailboxes, window.app.mails
    @set_layout_menu()
    
  resize: ->
    viewport = ->
      e = window
      a = "inner"
      unless "innerWidth" of window
        a = "client"
        e = document.documentElement or document.body
      e[a + "Height"]
    $("body").height viewport() - 10
    $("#content").height viewport() - 10
    $(".column").height viewport() - 10

    
###################################################
## COMMON
###################################################
        
  # layout the dynamic menu
  set_layout_menu: ->
    
    # set ut the menu view
    @container_menu.html require('./templates/menu')
    window.app.view_menu = new MenuMailboxesList @.$("#menu_mailboxes"), window.app.mailboxes
    
    # fetch necessary data
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        window.app.mailboxes.trigger("change_active_mailboxes")
        console.log "Initial menu mailboxes load OK"
        window.app.view_menu.render()
      })

###################################################
## LAYOUTS
###################################################

  # put on the layout to display mailboxes:
  set_layout_mailboxes: ->
    
    # ensure the right size
    @set_layout_menu()
    
    # lay the mailboxes out
    @container_content.html require('./templates/_layouts/layout_mailboxes')
    window.app.view_mailboxes = new MailboxesList @.$("#mail_list_container"), window.app.mailboxes
    window.app.view_mailboxes_new = new MailboxesListNew @.$("#add_mail_button_container"), window.app.mailboxes
    window.app.view_mailboxes_new.render()
    
    # fetch necessary data
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        console.log "Initial mailbox view mailboxes load OK"
      })
    
    # ensure the right size
    @resize()


  # put on the layout to display mailboxes:
  set_layout_compose_mail: ->

    # ensure the right size
    @set_layout_menu()

    # lay the mailboxes out
    @container_content.html require('./templates/_layouts/layout_compose_mail')
    window.app.view_compose_mail = new MailsCompose @.$("#compose_mail_container"), window.app.mailboxes

    # fetch necessary data
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        console.log "Initial compose view mailboxes load OK"
        window.app.view_compose_mail.render()
      })

    # ensure the right size
    @resize()

  # put on the layout to display mails:
  set_layout_mails: ->
    
    # set menu
    @set_layout_menu()
    
    # lay the mails out
    @container_content.html require('./templates/_layouts/layout_mails')
    
    # create views for the columns
    window.app.view_mails_list = new MailsColumn @.$("#column_mails_list"), window.app.mails
    window.app.view_mails_list.render()
    window.app.view_mail = new MailsElement @.$("#column_mail"), window.app.mails
    
    # fetch necessary data
    window.app.mailboxes.fetch({
      success: ->
        console.log "Initial mails mailboxes load OK"
        # fetch necessary data
        window.app.mails.fetchOlder () ->
            console.log "Initial mails mails load OK"
            window.app.mailboxes.updateActiveMailboxes()
      })
    
    # ensure the right size
    @resize()