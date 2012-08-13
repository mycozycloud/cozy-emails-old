{Mail} = require "../models/mail"
{MailsAnswer} = require "../views/mails_answer"

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

  ###
      CLICK ACTIONS
  ###
  
  create_answer_view: ->
    unless window.app.view_answer
      console.log "create new answer view"
      window.app.view_answer = new MailsAnswer @.$("#answer_form"), @collection.activeMail
      window.app.view_answer.render()

  bt_answer_all: ->
    console.log "answer all"
    @create_answer_view()

  bt_answer: ->
    console.log "answer"
    @create_answer_view()

  bt_forward: ->
    console.log "forward"
    @create_answer_view()

  render: ->
    if window.app.view_answer
      delete window.app.view_answer
      console.log "delete answer view"
    $(@el).html ""
    template = require('./templates/_mail/mail_big')
    if @collection.activeMail?
      $(@el).html template("model" : @collection.activeMail)
    @