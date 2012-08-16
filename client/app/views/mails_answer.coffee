{Mail} = require "../models/mail"
{MailNew} = require "../models/mail_new"

###

  The mail view. Displays all data & options

###
class exports.MailsAnswer extends Backbone.View

  constructor: (@el, @mail, @mailtosend) ->
    super()
    @mail.on "change", @render, @
  
  events: {
    "click a#send_button" : 'send'
  }
  
  send: ->
    input = @.$(".content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value
    
    @mailtosend.set data 
    @mailtosend.url = "sendmail/" + @mail.get("mailbox")
    console.log @mailtosend
    @mailtosend.save()
    $(@el).html require('./templates/_mail/mail_sent')

  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_answer')
    $(@el).html template({"model" : @mail, "mailtosend" : @mailtosend})
    @