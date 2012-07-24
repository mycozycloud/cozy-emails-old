# Row displaying task status and description
class exports.MailboxMenuView extends Backbone.View
  tagName: 'li'

  constructor: (@model, @collection) ->
    super()

  # Render wiew and bind it to model.
  render: ->
    template = require('./templates/mailbox_menu')
    $(@el).html template("model": @model.toJSON())
    @
