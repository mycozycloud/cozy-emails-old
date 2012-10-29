{Mail} = require "../models/mail"
{MailsAnswer} = require "../views/mails_answer"
{MailNew} = require "../models/mail_new"

###
  @file: mails_compose.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The new mail view, gives the choixe between configured mailboxes and makes it possible to send data.
###

class exports.MailsCompose extends Backbone.View

  events: {
    "click a#send_button" : 'prepareSend'
  }
  
  constructor: (@el, @collection) ->
    super()
    @mailtosend = new MailNew()

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
    @mailtosend.url = "sendmail/" + window.app.mailboxes.get(data["mailbox"])?.get("id")
    el = @el

    # send, and collect the server's response
    @mailtosend.save(data,
      success: ->
        # success, let's render it
        console.log "sent!"
        $(el).html require('./templates/_mail/mail_sent')
        # message box
        window.app.logmessages.add {"type": "success", "text": "Message was saved in cozy, and will be sent as soon as possible.", "createdAt": new Date().valueOf, "timeout": 5}
      error: ->
        # success, let's render it
        console.log "error!"
        # message box
        window.app.logmessages.create {"type": "error", "text": "Message could not be sent. Check your mailbox settings", "createdAt": new Date().valueOf, "timeout": 0}
    )
    
    console.log "sending mail: " + @mailtosend


  # render, including the wysihtml5 rich text editor
  render: ->
    template = require('./templates/_mail/mail_compose')
    $(@el).html template({"models" : @collection.models})
    
    try
      editor = new wysihtml5.Editor("html", # id of textarea element
        toolbar: "wysihtml5-toolbar" # id of toolbar element
        parserRules: wysihtml5ParserRules # defined in parser rules set
        stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"],
      )
    catch error
      console.log error.toString()