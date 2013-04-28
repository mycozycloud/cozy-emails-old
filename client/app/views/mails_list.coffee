{Mail} = require "../models/mail"
{MailsListElement} = require "./mails_list_element"

###
    @file: mails_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        View to generate the list of mails - the second column from the left.
        Uses MailsListElement to generate each mail's view
###

class exports.MailsList extends Backbone.View
    id: "mails_list"

    constructor: (@el, @collection) ->
        super()
        @collection.view = @

    initialize: ->
        @collection.on 'reset', @render, @
        @collection.on "add", @treatAdd, @

    # this function decides whether to add the new fetched mail on the top (new
    # mail), or the bottom ("more mails" button) of the list.
    treatAdd: (mail) ->
        dateValueOf = mail.get "dateValueOf"

        # check if we are adding a new message, or an old one
        if dateValueOf < @collection.timestampNew
            # update timestamp for the list of messages
            if dateValueOf < @collection.timestampOld
                @collection.timestampOld = dateValueOf
                @collection.lastIdOld = mail.get("id")

            # add its view at the bottom of the list
            @addOne mail
        else
            # update timestamp for new messages
            if dateValueOf > @collection.timestampNew
                @collection.timestampNew = dateValueOf
                @collection.lastIdNew = mail.get("id")

            # add its view on top of the list
            @addNew mail

    addOne: (mail) ->
        box = new MailsListElement mail, @collection
        @$el.append box.render().el

    addNew: (mail) ->
        box = new MailsListElement mail, @collection
        @$el.prepend box.render().el

    render: ->
        @$el.html ""
        @collection.each (mail) =>
            @addOne mail
        @
