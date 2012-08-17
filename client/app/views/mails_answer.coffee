{Mail} = require "../models/mail"
{MailNew} = require "../models/mail_new"

###

  The mail view. Displays all data & options

###
class exports.MailsAnswer extends Backbone.View

  constructor: (@el, @mail, @mailtosend) ->
    super()
    @mail.on "change", @render, @
    @mailtosend.on "change", @render, @

  events: {
    "click a#send_button" : 'send'
    "click a#mail_detailed_view_button" : 'view_advanced'
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


  set_basic: (show=true)->
    if show
      @.$("#mail_basic").show()
    else
      @.$("#mail_basic").hide()
  set_to: (show=true)->
    if show
      @.$("#mail_to").show()
    else
      @.$("#mail_to").hide()
  set_advanced: (show=true)->
    if show
      @.$("#mail_advanced").show()
    else
      @.$("#mail_advanced").hide()
    

  view_advanced: ->
    @set_basic false
    @set_to true
    @set_advanced true

  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_answer')
    $(@el).html template({"model" : @mail, "mailtosend" : @mailtosend})
    editor = new wysihtml5.Editor("html", # id of textarea element
      toolbar: "wysihtml5-toolbar" # id of toolbar element
      parserRules: wysihtml5ParserRules # defined in parser rules set
      stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"],
    )
    @set_basic true
    @set_to false
    @set_advanced false
    @