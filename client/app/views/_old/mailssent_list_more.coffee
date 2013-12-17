{MailSent} = require "models/mail_sent"

###
  @file: mailssent_list_more.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    The view with the "load more" button.
    Also displays info on how many messages are visible in this filer, and how many are effectiveley downloaded.

###
class exports.MailsSentListMore extends Backbone.View

  # variable to avoid multiple requests with the same params
  clickable: true
  disabled: false

  constructor: (@el, @collection) ->
    super()

  initialize: ->
    @collection.on 'reset', @render, @
    @collection.on 'add', @render, @
    @collection.on 'updated_number_mails_shown', @render, @
    window.app.mailboxes.on "change_active_mailboxes", @render, @

  events: {
     "click #add_more_mails" : 'loadOlderMails',
  }

  # when user clicks on "more mails" button
  loadOlderMails: () ->
    # disable the button
    $("#add_more_mails").addClass("disabled")

    # if not disabled
    if @clickable
      # fetch new data
      success = (collection) ->
        window.app.mailssent.trigger "update_number_mails_shown"

      error = (collection, error) =>
        if error.status == 499
          @disabled = true
          @render()

      @collection.fetchOlder(success, error)
      @clickable = false
      element = @
      # in case it doesn't work, unblock after some time
      setTimeout(
        () ->
          element.clickable = true
          element.render()
          console.log "retry"
        , 1000 * 7
      )

  render: ->
    # unblock the button
    @clickable = true
    template = require "./templates/_mail/mails_more"
    $(@el).html template({"collection" : @collection, "disabled": @disabled})
    @