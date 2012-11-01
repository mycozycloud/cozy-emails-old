{Mail} = require "../models/mail"

###
  @file: mails_list_new.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The view with the "load new" button.

###
class exports.MailsListNew extends Backbone.View
  
  # variable to avoid multiple requests with the same params
  clickable: true

  constructor: (@el, @collection) ->
    super()
    
  initialize: ->
    @collection.on 'reset', @render, @

  events: {
     "click #get_new_mails" : 'loadNewMails',
  }
  
  # when user clicks on "more mails" button
  loadNewMails: () ->

    element = @

    # if not disabled
    if @clickable

      # display - working
      @clickable = false
      $("#get_new_mails").addClass("disabled").text("Checking for new mail...")

      # fetch new data
      # $.ajax "fetchandwait/" + @model.id, {
      #  complete: () ->
      #    window.app.mails.fetchNew ->
      #
      #      $("#get_new_mails").removeClass("disabled").text("Check completed!")
      # }

      window.app.mails.fetchNew ->
        element.clickable = true
        date = new Date()
        dateString = date.getHours() + ":"
        if date.getMinutes() < 10
          dateString += "0" + date.getMinutes()
        else
          dateString += date.getMinutes()
        $("#get_new_mails").removeClass("disabled").text("Last check at " + dateString)

      
      # in case it doesn't work, unblock after some time
      setTimeout(
        () ->
          element.clickable = true
          $("#get_new_mails").removeClass("disabled")
        , 1000 * 4
      )
  
  render: ->
    # unblock the button
    @clickable = true
    template = require "./templates/_mail/mail_new"
    $(@el).html template({"collection" : @collection})
    @