{Mail} = require "../models/mail"
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
    app.appView.set_layout_mails()
    $(".menu_option").removeClass("active")
    $("#inboxbutton").addClass("active")


################################################################
############## NEW MAIL 
  new : ->
    app.appView.set_layout_compose_mail()
    $(".menu_option").removeClass("active")
    $("#newmailbutton").addClass("active")


################################################################
############## CONFIG

  configMailboxes : ->
    app.appView.set_layout_mailboxes()
    $(".menu_option").removeClass("active")
    $("#mailboxesbutton").addClass("active")
    
################################################################
############## INDEX
  mail : (path) ->
    app.appView.set_layout_mails()
    
    # if the mail is already downloaded, show it
    if app.mails.get(path)?
      app.mails.activeMail = app.mails.get(path)
      app.mails.trigger "change_active_mail"
    # otherwise, download it
    else
      app.mails.activeMail = new Mail {id: path}
      app.mails.activeMail.url = "mails/" + path
      app.mails.activeMail.fetch({
        success : ->
          app.mails.trigger "change_active_mail"
      })