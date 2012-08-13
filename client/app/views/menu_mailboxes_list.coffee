{MenuMailboxListElement} = require "./menu_mailboxes_list_element"

###

  The list of mailboxes in the leftmost column - the menu.

###
class exports.MenuMailboxesList extends Backbone.View
  
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
    @collection.each (mailbox) =>
      box = new MenuMailboxListElement mailbox, @collection
      $(@el).append box.render().el
      @total_inbox += (Number) mailbox.get("new_messages")
    @