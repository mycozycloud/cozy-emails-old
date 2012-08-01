{Mail} = require "../models/mail"

{MailsListElement} = require "./mails_list_element"

###

  View to generate the list of mails - the second column from the left.
  Uses MailsListElement to generate each mail's view

###
class exports.MailsList extends Backbone.View
  id: "mails_list"

  constructor: (@el, @collection) ->
    super()
    @collection.view = @

  initialize: ->
    @collection.on('reset', @render, @)
    @collection.fetch()

  addOne: (mail) ->
    box = new MailsListElement mail, mail.collection
    $(@el).append box.render().el    

  render: ->
    $(@el).html ""
    @collection.each (m) =>
      @addOne m
    @