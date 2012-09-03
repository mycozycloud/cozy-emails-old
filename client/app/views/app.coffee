{MailboxesList} = require '../views/mailboxes_list'
{MailboxesListNew} = require '../views/mailboxes_list_new'
{MenuMailboxesList} = require '../views/menu_mailboxes_list'
{MailsColumn} = require '../views/mails_column'
{MailsElement} = require '../views/mails_element'
{MailsCompose} = require '../views/mails_compose'
{MessageBox} = require 'views/message_box'

###
  @file: app.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The application's main view - creates other views, lays things out.

###

class exports.AppView extends Backbone.View

  el: 'body'

  initialize: ->
    # capture the resize event, to adjust the size of UI
    window.onresize = @resize
    
    # put on the big layout
    $(@el).html require('./templates/app')
    @containerMenu = @.$("#menu_container")
    @containerContent = @.$("#content")
    @viewMessageBox = new MessageBox @.$("#message_box"), window.app.mailboxes, window.app.mails
    @setLayoutMenu()
  
  # making sure the view takes 100% height of the viewport.
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
  setLayoutMenu: ->
    
    # set ut the menu view
    @containerMenu.html require('./templates/menu')
    window.app.viewMenu = new MenuMailboxesList @.$("#menu_mailboxes"), window.app.mailboxes
    
    # fetch necessary data
    window.app.mailboxes.reset()
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        window.app.mailboxes.trigger("change_active_mailboxes")
        console.log "Initial menu mailboxes load OK"
        window.app.viewMenu.render()
      })

###################################################
## LAYOUTS
###################################################

  # put on the layout to display mailboxes:
  setLayoutMailboxes: ->
    
    # ensure the right size
    @setLayoutMenu()
    
    # lay the mailboxes out
    @containerContent.html require('./templates/_layouts/layout_mailboxes')
    window.app.viewMailboxes = new MailboxesList @.$("#mail_list_container"), window.app.mailboxes
    window.app.viewMailboxesNew = new MailboxesListNew @.$("#add_mail_button_container"), window.app.mailboxes
    window.app.viewMailboxesNew.render()
    
    # fetch necessary data
    window.app.mailboxes.reset()
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        console.log "Initial mailbox view mailboxes load OK"
      })
    
    # ensure the right size
    @resize()



  # put on the layout to display mailboxes:
  setLayoutComposeMail: ->

    # ensure the right size
    @setLayoutMenu()

    # lay the mailboxes out
    @containerContent.html require('./templates/_layouts/layout_compose_mail')
    window.app.viewComposeMail = new MailsCompose @.$("#compose_mail_container"), window.app.mailboxes

    # fetch necessary data
    window.app.mailboxes.reset()
    window.app.mailboxes.fetch({
      success: ->
        window.app.mailboxes.updateActiveMailboxes()
        console.log "Initial compose view mailboxes load OK"
        window.app.viewComposeMail.render()
      })

    # ensure the right size
    @resize()



  # put on the layout to display mails:
  setLayoutMails: ->
    
    # set menu
    @setLayoutMenu()
    
    # lay the mails out
    @containerContent.html require('./templates/_layouts/layout_mails')
    
    # create views for the columns
    window.app.viewMailsList = new MailsColumn @.$("#column_mails_list"), window.app.mails
    window.app.viewMailsList.render()
    window.app.view_mail = new MailsElement @.$("#column_mail"), window.app.mails
    
    # fetch necessary data
    window.app.mailboxes.reset()
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