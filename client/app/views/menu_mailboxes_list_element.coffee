###

  The element of the list of mailboxes in the leftmost column - the menu.

###
class exports.MenuMailboxListElement extends Backbone.View
  tagName: 'li'

  constructor: (@model, @collection) ->
    super()

  render: ->
    template = require('./templates/_mailbox/mailbox_menu')
    $(@el).html template("model": @model.toJSON())
    @
