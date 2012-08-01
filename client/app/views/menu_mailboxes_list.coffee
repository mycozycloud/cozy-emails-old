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
    "change input.change_mailboxes_list" : 'setupMailboxes',
  }

  setupMailboxes: (event) ->
    input = $("input.change_mailboxes_list")
    data = {}
    for element in input
      data[element.id] = true if element.checked
    @collection.active_mailboxes = data
    @collection.trigger "change_active_mailboxes"
    # console.log @collection.active_mailboxes

  render: ->
    $(@el).html("")
    @total_inbox = 0
    @collection.each (mail) =>
      box = new MenuMailboxListElement mail, mail.collection
      $(@el).append box.render().el
      @total_inbox += (Number) mail.get("new_messages")
    @