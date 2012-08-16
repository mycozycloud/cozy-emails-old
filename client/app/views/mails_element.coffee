{Mail} = require "../models/mail"
{MailsAnswer} = require "../views/mails_answer"
{MailNew} = require "../models/mail_new"

###

  The mail view. Displays all data & options

###
class exports.MailsElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @
    window.app.mailtosend = new MailNew()
    
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

  bt_answer_all: ->
    console.log "answer all"
    @create_answer_view()
    window.app.mailtosend.set "mode", "answer_all"

  bt_answer: ->
    console.log "answer"
    @create_answer_view()
    window.app.mailtosend.set "mode", "answer"

  bt_forward: ->
    console.log "forward"
    @create_answer_view()
    window.app.mailtosend.set "mode", "forward"
    
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
    template = require('./templates/_mail/mail_big')
    if @collection.activeMail?
      $(@el).html template("model" : @collection.activeMail)
    @