###

  The element of the list of mailboxes in the leftmost column - the menu.

###
class exports.MenuMailboxListElement extends Backbone.View
  tagName: 'li'

  constructor: (@model, @collection) ->
    super()
    
  events: {
    "click" : 'setupMailbox'
  }

  setupMailbox: (event) ->
    @model.set("checked", not @model.get("checked"))
    @model.save()
    @collection.updateActiveMailboxes()
    @collection.trigger("change_active_mailboxes")

  render: ->
    template = require('./templates/_mailbox/mailbox_menu')
    $(@el).html template("model": @model.toJSON())
    @
