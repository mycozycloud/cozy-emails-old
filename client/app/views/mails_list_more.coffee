{Mail} = require "../models/mail"

###

  The view with the "load more" button.

###
class exports.MailsListMore extends Backbone.View
  
  # variable to avoid multiple requests with the same params
  clickable: true

  constructor: (@el, @collection) ->
    super()
    
  initialize: ->
    @collection.on('reset', @render, @)
    @collection.on('add', @render, @)
    window.app.mailboxes.on "change_active_mailboxes", @render, @

  events: {
     "click #add_more_mails" : 'loadOlderMails',
  }
  
  # prepares 
  loadOlderMails: () ->
    # disable the button
    $("#add_more_mails").addClass("disabled")
    
    # if not disabled
    if @clickable
      # fetch new data
      @collection.fetchOlder()
      @clickable = false
      element = @
      # in case it doesn't work, unblock after some time
      setTimeout(
        () ->
          element.clickable = true
          element.render()
          console.log "retry"
        , 1000 * 10
      )
  
  render: ->
    # unblock the button
    @clickable = true
    template = require "./templates/_mail/mails_more"
    $(@el).html template({"collection" : @collection})
    @