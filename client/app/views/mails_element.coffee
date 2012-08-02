{Mail} = require "../models/mail"

###

  The mail view. Displays all data & options

###
class exports.MailsElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @

  render: ->
    @collection.activeMail.prerender()
    template = require('./templates/_mail/mail_big')
    $(@el).html template("model" : @collection.activeMail.toJSON())
    @.$("#mail_content").html @.$("#mail_content").text()
    @