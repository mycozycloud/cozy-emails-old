{Mail} = require "../models/mail"

###

  The mail view. Displays all data & options

###
class exports.MailsAnswer extends Backbone.View

  constructor: (@el, @mail) ->
    super()
    

  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_answer')
    $(@el).html template("model" : @mail)
    @