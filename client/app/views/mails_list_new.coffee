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

    events:
         "click #get_new_mails": 'loadNewMails',
    
    # when user clicks on "more mails" button
    loadNewMails: ->
        element = @

        if @clickable

            @clickable = false
            @$("#get_new_mails")
                .addClass("disabled")
                .text("Checking for new mail...")

            window.app.mails.fetchNew =>
                element.clickable = true
                date = new Date()
                @changeGetNewMailLabel date

            # in case it doesn't work, unblock after some time
            setTimeout( ->
                element.clickable = true
                @$("#get_new_mails").removeClass("disabled")
            , 1000 * 4)
    
    changeGetNewMailLabel: (date) ->
        dateString = date.getHours() + ":"
        if date.getMinutes() < 10
            dateString += "0" + date.getMinutes()
        else
            dateString += date.getMinutes()

        @$("#get_new_mails").removeClass "disabled"
        msg = "Check for new mail (Last check at #{dateString})"
        @$("#get_new_mails").text msg

    render: ->
        @clickable = true
        template = require "./templates/_mail/mail_new"
        @$el.html template(collection: @collection)
        @
