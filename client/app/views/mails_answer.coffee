{Mail} = require "../models/mail"
{MailNew} = require "../models/mail_new"

###
  @file: mails_answer.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The mail response view. Created when user clicks "answer"
###

class exports.MailsAnswer extends Backbone.View

  constructor: (@el, @mail, @mailtosend) ->
    super()
    @mail.on "change", @render, @
    @mailtosend.on "change_mode", @render, @

  events: {
    "click a#send_button" : 'prepareSend'
    "click a#mail_detailed_view_button" : 'viewAdvanced'
  }
  
  
  # prepares data to save in @mailtosend object, which will be sent to server side
  prepareSend: (event) ->
    
    # disable the button
    $(event.target).addClass("disabled").removeClass("buttonSave")
    @.$(".content").addClass("disabled")
    
    # get the data
    input = @.$(".content")
    data = {}
    input.each (i) ->
      data[input[i].id] = input[i].value
      
    # set the url to take into account the id of the mailbox
    @mailtosend.url = "sendmail/" + @mail.get("mailbox")
    el = @el

    # send, and collect the server's response
    @mailtosend.save(data,
      success: ->
        # success, let's render it
        console.log "sent!"
        $(el).html require('./templates/_mail/mail_sent')
        # message box
        window.app.appView.viewMessageBox.renderMessageSentSuccess()
      error: ->
        # success, let's render it
        console.log "error!"
        # message box
        window.app.appView.viewMessageBox.renderMessageSentError()
    )
    
    console.log "sending mail: " + @mailtosend

  
  # set the visibility of 3 parts of answer view
  setBasic: (show=true)->
    if show
      @.$("#mail_basic").show()
    else
      @.$("#mail_basic").hide()
  setTo: (show=true)->
    if show
      @.$("#mail_to").show()
    else
      @.$("#mail_to").hide()
  setAdvanced: (show=true)->
    if show
      @.$("#mail_advanced").show()
    else
      @.$("#mail_advanced").hide()
  
  # unlock additional data
  viewAdvanced: ->
    @setBasic false
    @setTo true
    @setAdvanced true

  # render, including the wysihtml5 rich text editor
  render: ->
    $(@el).html ""
    template = require('./templates/_mail/mail_answer')
    $(@el).html template({"model" : @mail, "mailtosend" : @mailtosend})
    
    try
      editor = new wysihtml5.Editor("html", # id of textarea element
        toolbar: "wysihtml5-toolbar" # id of toolbar element
        parserRules: wysihtml5ParserRules # defined in parser rules set
        stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"],
      )
    catch error
      console.log error
    @setBasic true
    @setTo false
    @setAdvanced false
    @