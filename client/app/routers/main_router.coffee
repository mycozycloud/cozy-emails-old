###

  Application's router.

###
class exports.MainRouter extends Backbone.Router

  routes:
    '' : 'home'
    'config-mailboxes' : 'configMailboxes'

  # routes that need regexp.
  initialize: ->
    @route(/^mail\/(.*?)$/, 'mail')

################################################################
############## INDEX
  home : ->
    app.appView.render()
    app.appView.set_layout_mails()


################################################################
############## CONFIG

  configMailboxes : ->
    app.appView.render()
    app.appView.set_layout_mailboxes()
    
    
################################################################
############## INDEX
  mail : (path) ->
    app.appView.render()
    app.appView.set_layout_mails()
    
    if app.mails.get(path)?
      app.mails.activeMail = app.mails.get(path)
      app.mails.trigger "change_active_mail"