{MailboxMenuView} = require "./mailbox_menu_view"

class exports.MailboxesMenuList extends Backbone.View
  
  total_inbox: 0
  
  constructor: (@el, @collection) ->
    super() 
    window.app.mailboxes.on('reset', @render, @)
    window.app.mailboxes.on('add', @render, @)
    window.app.mailboxes.on('remove', @render, @)
    window.app.mailboxes.on('change', @render, @)

  render: ->
    $(@el).html("")
    @total_inbox = 0
    @collection.each (mail) =>
      box = new MailboxMenuView mail, mail.collection
      $(@el).append box.render().el
      @total_inbox += (Number) mail.get("new_messages")
    @