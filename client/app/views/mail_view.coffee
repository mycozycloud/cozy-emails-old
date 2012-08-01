{Mail} = require "../models/mail"

class exports.MailColumnView extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @

  render: ->
    template = require('./templates/_mail/mail_big')
    console.log @collection.activeMail
    $(@el).html template("model" : @collection.activeMail?.toJSON())
    @