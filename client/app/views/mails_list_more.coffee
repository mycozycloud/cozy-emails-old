{Mail} = require "../models/mail"

###

  The view with the "load more" button.

###
class exports.MailsListMore extends Backbone.View

  constructor: (@el, @collection) ->
    super()

  render: ->
    $(@el).html require "./templates/_mail/mails_more"
    @