{Mail} = require "../models/mail"

###
    @file: mails.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The collection to store emails - gets populated with the content of
        the database.
###
class exports.MailsCollection extends Backbone.Collection

    model: Mail
    url: 'mails/'

    # timestamps:
    #     * timestampMiddle doesn't change - shows which mails are "new"
    #       (fetched after rendering of the interface), and the "old" ones
    #     * timestampNew - the newest mail (sort, and next queries of fetchNew
    #       ask for newer)
    #     * timestampOld - the oldest mail (sort and next quesries ask fof
    #       olders ("load more" button))
    timestampNew: new Date().valueOf()
    timestampOld: new Date().valueOf()
    timestampMiddle: new Date().valueOf()

    # number of mails to fetch at one click on "more mail" button
    mailsAtOnce: 100

    initialize: ->
        @on "change_active_mail", @navigateMail, @
        @on "update_number_mails_shown", @calculateMailsShown, @
        setInterval @fetchNew, 1000 * 30

    setActiveMail: (mail) ->
        @activeMail?.view?.active = false
        @activeMail?.view?.render()
        @activeMail = mail
        @activeMail.view.active = true

    setActiveMailAsRead: ->
        @activeMail.setRead()
        @activeMail.url = "mails/#{@activeMail.get("id")}"
        @activeMail.save read: true

    # sets the url to the active mail, chosen by user (for browser history to work, for example)
    navigateMail: (event) ->
        if @activeMail?
            window.app.router.navigate "mail/#{@activeMail.id}"
        else
            console.error "NavigateMail without active mail"

    # fetches older mails (the list of mails)
    fetchOlder: (callback, errorCallback) ->
        @url = "mails/#{@timestampOld}/#{@mailsAtOnce}/#{@lastIdOld}"
        @fetch
            add: true
            success: (models) =>
                if models.length > 0
                    @timestampNew = models.at(0).get("dateValueOf")
                callback models.length

            error: errorCallback

    # fetches new mails from server
    fetchNew: (callback) =>
        @url = "mails/new/#{@timestampNew}/"
        $.ajax 'mails/fetch-new/',
            success: =>
                @fetch
                    add: true
                    success: (models) =>
                        callback null, data if callback?
                    error: ->
                        alert "Fetch new mail failed"
