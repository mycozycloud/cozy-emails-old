{Mail} = require "../models/mail"
{MailsAnswer} = require "../views/mails_answer"
{MailNew} = require "../models/mail_new"
{MailsAttachmentsList} = require "../views/mails_attachments_list"
###

  The mail view. Displays all data & options

###
class exports.MailsElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @
    
  events:
    "click a#button_answer_all" : 'bt_answer_all'
    "click a#button_answer" : 'bt_answer'
    "click a#button_forward" : 'bt_forward'
    "click a#button_unread" : 'bt_unread'
    "click a#button_flagged" : 'bt_flagged'

  ###
      CLICK ACTIONS
  ###
  
  create_answer_view: ->
    unless window.app.view_answer
      console.log "create new answer view"
      window.app.view_answer = new MailsAnswer @.$("#answer_form"), @collection.activeMail, window.app.mailtosend
      window.app.view_answer.render()
  
  scrollDown: ->
    # console.log "scroll: " + $("#column_mail").outerHeight true
    # scroll down
    setTimeout () ->
      $("#column_mail").animate({scrollTop: 2 * $("#column_mail").outerHeight true}, 750)
    , 250

  bt_answer_all: ->
    
    console.log "answer all"
    @create_answer_view()
    window.app.mailtosend.set 
      mode: "answer_all"
    window.app.view_answer.setBasic true
    window.app.view_answer.setTo false
    window.app.view_answer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"
    
    # scroll down the view, to show the answer form
    @scrollDown()

  bt_answer: ->
    console.log "answer"
    @create_answer_view()
    window.app.mailtosend.set 
      mode: "answer"
    window.app.view_answer.setBasic true
    window.app.view_answer.setTo false
    window.app.view_answer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"
    
    # scroll down the view, to show the answer form
    @scrollDown()
    
  bt_forward: ->
    console.log "forward"
    @create_answer_view()
    window.app.mailtosend.set 
      mode: "forward"
    window.app.view_answer.setBasic true
    window.app.view_answer.setTo true
    window.app.view_answer.setAdvanced false
    
    window.app.mailtosend.trigger "change_mode"

    # scroll down the view, to show the answer form
    @scrollDown()
    
  bt_unread: ->
    console.log "unread"
    @collection.activeMail.set_read(false)
    @collection.activeMail.url = "mails/" + @collection.activeMail.get("id")
    @collection.activeMail.save()
      
  bt_flagged: ->
    if @collection.activeMail.is_flagged()
      console.log "unflagged"
      @collection.activeMail.set_flagged(false)
    else
      @collection.activeMail.set_flagged(true)
      console.log "flagged"
    @collection.activeMail.url = "mails/" + @collection.activeMail.get("id")
    @collection.activeMail.save()

  render: ->
    
    if window.app.view_answer
      delete window.app.view_answer
      console.log "delete answer view"
    
    $(@el).html ""
    
    if @collection.activeMail?
      
      template = require('./templates/_mail/mail_big')
      
      $(@el).hide()
      
      $(@el).html template("model" : @collection.activeMail)
      
      if @collection.activeMail.hasHtml()
        setTimeout () =>
          $("#mail_content_html").contents().find("html").html @collection.activeMail.html()
          # frames["mail_content_html"].document.documentElement.innerHTML = @collection.activeMail.html()
          
          # add some basic styling and targeting to the internal document
          $("#mail_content_html").contents().find("head").append '<link rel="stylesheet" href="css/reset_bootstrap.css">'
          $("#mail_content_html").contents().find("head").append '<base target="_blank">'
        
          # adjust the height of the iframe
          $(@el).show()
          $("#mail_content_html").height $("#mail_content_html").contents().find("html").height()
          
        , 1
        
        window.app.view_attachments = new MailsAttachmentsList $("#attachments_list"), @collection.activeMail
      else
        $(@el).show()
    @