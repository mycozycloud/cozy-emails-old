{Mail} = require "../models/mail"
{MailsAnswer} = require "../views/mails_answer"
{MailNew} = require "../models/mail_new"
{MailsAttachmentsList} = require "../views/mails_attachments_list"

###
  @file: mails_element.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The mail view. Displays all data & options.
    Also, handles buttons.

###

class exports.MailsElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @
    
  events:
    "click a#button_answer_all" : 'buttonAnswerAll'
    "click a#button_answer" : 'buttonAnswer'
    "click a#button_forward" : 'buttonForward'
    "click a#button_unread" : 'buttonUnread'
    "click a#button_flagged" : 'buttonFlagged'

  ###
      CLICK ACTIONS
  ###
  
  createAnswerView: ->
    unless window.app.viewAnswer
      console.log "create new answer view"
      window.app.viewAnswer = new MailsAnswer @.$("#answer_form"), @collection.activeMail, window.app.mailtosend
      window.app.viewAnswer.render()
  
  scrollDown: ->
    # console.log "scroll: " + $("#column_mail").outerHeight true
    # scroll down
    setTimeout () ->
      $("#column_mail").animate({scrollTop: 2 * $("#column_mail").outerHeight true}, 750)
    , 250

  # handles click on button to answet to all
  buttonAnswerAll: ->
    
    console.log "answer all"
    @createAnswerView()
    window.app.mailtosend.set 
      mode: "answer_all"
    window.app.viewAnswer.setBasic true
    window.app.viewAnswer.setTo false
    window.app.viewAnswer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"
    
    # scroll down the view, to show the answer form
    @scrollDown()

  # handles the click on answer button
  buttonAnswer: ->
    console.log "answer"
    @createAnswerView()
    window.app.mailtosend.set 
      mode: "answer"
    window.app.viewAnswer.setBasic true
    window.app.viewAnswer.setTo false
    window.app.viewAnswer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"
    
    # scroll down the view, to show the answer form
    @scrollDown()
  
  # handles forward button
  buttonForward: ->
    console.log "forward"
    @createAnswerView()
    window.app.mailtosend.set 
      mode: "forward"
    window.app.viewAnswer.setBasic true
    window.app.viewAnswer.setTo true
    window.app.viewAnswer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"

    # scroll down the view, to show the answer form
    @scrollDown()
  
  # handles unread button
  buttonUnread: ->
    console.log "unread"
    @collection.activeMail.setRead(false)
    @collection.activeMail.url = "mails/" + @collection.activeMail.get("id")
    @collection.activeMail.save()
  
  # handles flagged button
  buttonFlagged: ->
    if @collection.activeMail.isFlagged()
      console.log "unflagged"
      @collection.activeMail.setFlagged(false)
    else
      @collection.activeMail.setFlagged(true)
      console.log "flagged"
    @collection.activeMail.url = "mails/" + @collection.activeMail.get("id")
    @collection.activeMail.save()

  render: ->
    
    if window.app.viewAnswer
      delete window.app.viewAnswer
      console.log "delete answer view"
    
    $(@el).html ""
    
    if @collection.activeMail?
      
      template = require('./templates/_mail/mail_big')
      
      $(@el).html template("model" : @collection.activeMail)
      
      if @collection.activeMail.hasHtml()
        
        # this timeout is a walkaround the firefox empty iframe onLoad issue.
        setTimeout () =>
          $("#mail_content_html").contents().find("html").html @collection.activeMail.html()
          # frames["mail_content_html"].document.documentElement.innerHTML = @collection.activeMail.html()
          
          # add some basic styling and targeting to the internal document
          $("#mail_content_html").contents().find("head").append '<link rel="stylesheet" href="css/reset_bootstrap.css">'
          $("#mail_content_html").contents().find("head").append '<base target="_blank">'
        
          # adjust the height of the iframe
          $("#mail_content_html").height $("#mail_content_html").contents().find("html").height()
          
        , 1
        
        window.app.viewAttachments = new MailsAttachmentsList $("#attachments_list"), @collection.activeMail
    @