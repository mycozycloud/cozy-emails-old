{Mail} = require "../models/mail"
{MailsSentListElement} = require "./mailssent_list_element"

###
  @file: mailssent_list.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    View to generate the list of sent mails - the second column from the left.
    Uses MailsListElement to generate each mail's view

###

class exports.MailsSentList extends Backbone.View
  id: "mails_list"

  constructor: (@el, @collection) ->
    super()
    @collection.view = @

  initialize: ->
    @collection.on 'reset', @render, @
    @collection.on "add", @addOne, @

  addOne: (mail) ->
    if Number(mail.get "createdAt") < @collection.timestampOld
      @collection.timestampOld = Number(mail.get "createdAt")
      @collection.lastIdOld = mail.get("id")
    box = new MailsSentListElement mail, @collection
    $(@el).append box.render().el

  render: ->
    $(@el).html ""
    col = @collection
    @collection.each (m) =>
      @addOne m
    @
