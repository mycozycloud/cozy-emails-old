{MailboxMenuView} = require "./mailbox_menu_view"

class exports.MailboxesMenuList extends Backbone.View
  
  somme: 0
  
  constructor: (@el, @collection) ->
    super() 
    @element = @el
    window.app.mailboxes.on('change', @render, @)
    window.app.mailboxes.on('add', @render, @)
    window.app.mailboxes.on('remove', @render, @)

  render: ->
    @collection.fetch()
    $(@el).html("")
    @somme = 0
    @collection.each (mail) =>
      box = new MailboxMenuView mail, mail.collection
      $(@el).append box.render().el
      @somme += (Number) mail.toJSON().new_messages
    @