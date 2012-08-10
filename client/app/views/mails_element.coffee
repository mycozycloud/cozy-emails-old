{Mail} = require "../models/mail"

###

  The mail view. Displays all data & options

###
class exports.MailsElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @

  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_big')
    if @collection.activeMail?
      $(@el).html template("model" : @collection.activeMail)
    @