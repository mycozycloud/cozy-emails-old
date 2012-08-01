{MailListView} = require "./mail_list_view"
{Mail} = require "../models/mail"

class exports.MailsMore extends Backbone.View

  constructor: (@el, @collection) ->
    super()

  render: ->
    $(@el).html require "./templates/_mail/mails_more"
    @