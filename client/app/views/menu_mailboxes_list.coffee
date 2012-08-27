{MenuMailboxListElement} = require "./menu_mailboxes_list_element"

###
  @file: menu_mailboxes_list.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The list of mailboxes in the menu

###

class exports.MenuMailboxesList extends Backbone.View
  
  total_inbox: 0
  
  constructor: (@el, @collection) ->
    super() 
    @collection.viewMenu_mailboxes = @
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