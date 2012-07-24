class exports.MainRouter extends Backbone.Router
  routes:
    '': 'home'

  home : ->
    app.appView.render()
    # app.appView.set_layout_mailboxes(app.appView)
	