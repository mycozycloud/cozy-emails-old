{Mail} = require "../models/mail"
{MailNew} = require "../models/mail_new"

###

  The mail view. Displays all data & options

###
class exports.MailsAnswer extends Backbone.View

  constructor: (@el, @mail) ->
    super()
  
  events: {
    "click a#send_button" : 'send'
  }
  
  send: ->
    input = @.$(".content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value;
    @model = new MailNew data
    console.log @model
    @model.url = "sendmail/" + @mail.get("mailbox")
    @model.save()

  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_answer')
    $(@el).html template("model" : @mail)
    @