{MailboxMenuView} = require "./mailbox_menu_view"

class exports.MailboxesMenuList extends Backbone.View
  
  total_inbox: 0
  
  constructor: (@el, @collection) ->
    super() 
    @collection.view_menu_mailboxes = @
    @collection.on('reset', @render, @)
    @collection.on('add', @render, @)
    @collection.on('remove', @render, @)
    @collection.on('change', @render, @)

  render: ->
    $(@el).html("")
    @total_inbox = 0
    @collection.each (mail) =>
      box = new MailboxMenuView mail, mail.collection
      $(@el).append box.render().el
      @total_inbox += (Number) mail.get("new_messages")
    @