###

  Application's router.

###
class exports.MainRouter extends Backbone.Router

  routes:
    '' : 'home'
    'config-mailboxes' : 'configMailboxes'

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
	