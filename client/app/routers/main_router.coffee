################################################################
###

  Application's router.

###
################################################################

class exports.MainRouter extends Backbone.Router

  routes:
    '' : 'home'
    'inbox' : 'home'
    'new-mail' : 'new'
    'config-mailboxes' : 'configMailboxes'

  # routes that need regexp.
  initialize: ->
    @route(/^mail\/(.*?)$/, 'mail')

################################################################
############## INDEX 
  home : ->
    app.appView.render()
    app.appView.set_layout_mails()
    $(".menu_option").removeClass("active")
    $("#inboxbutton").addClass("active")


################################################################
############## NEW MAIL 
  new : ->
    app.appView.render()
    app.appView.set_layout_mailboxes()
    $(".menu_option").removeClass("active")
    $("#newmailbutton").addClass("active")


################################################################
############## CONFIG

  configMailboxes : ->
    app.appView.render()
    app.appView.set_layout_mailboxes()
    $(".menu_option").removeClass("active")
    $("#mailboxesbutton").addClass("active")
    
################################################################
############## INDEX
  mail : (path) ->
    app.appView.render()
    app.appView.set_layout_mails()
    
    if app.mails.get(path)?
      app.mails.activeMail = app.mails.get(path)
      app.mails.trigger "change_active_mail"
    else
      app.mails.fetch({
        "success": ->
          if app.mails.get(path)?
            app.mails.activeMail = app.mails.get(path)
            app.mails.trigger "change_active_mail"
      })