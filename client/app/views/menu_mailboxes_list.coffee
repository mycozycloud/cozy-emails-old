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
    
  events: {
    "click .change_mailboxes_list" : 'setupMailbox'
  }

  setupMailbox: (event) ->
    id = event.target.getAttribute("mailbox_id")
    mb = @collection.get(id)
    mb.set("checked", not mb.get("checked"))
    mb.save()
    @collection.updateActiveMailboxes()
    @collection.trigger("change_active_mailboxes")
    console.log "yaha"

  render: ->
    $(@el).html("")
    @total_inbox = 0
    @collection.each (mail) =>
      box = new MenuMailboxListElement mail, mail.collection
      $(@el).append box.render().el
      @total_inbox += (Number) mail.get("new_messages")
    @