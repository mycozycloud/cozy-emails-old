class exports.MainRouter extends Backbone.Router
  routes:
    '': 'home'
    'config-mailboxes' : 'configMailboxes'

################################################################
############## CONFIG
  home : ->
    app.appView.render()


################################################################
############## CONFIG

  configMailboxes : ->
    app.appView.render()
    app.appView.set_layout_mailboxes()
	