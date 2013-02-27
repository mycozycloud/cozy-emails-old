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
    
    # variable to store number of mails visible in the active filter
    mailsShown: 0

    calculateMailsShown: ->
        #window.app.mails.trigger "update_number_mails_shown"
        #@model.get("mailbox") in window.app.mailboxes.activeMailboxes
        @mailsShown = 0
        @each (mail) =>
            if mail.get("mailbox") in window.app.mailboxes.activeMailboxes
                @mailsShown++
        @trigger "updated_number_mails_shown"
    
    # comparator to sort the collection with the date
    comparator: (mail) ->
        - mail.get("dateValueOf")
    
    initialize: ->
        @on "change_active_mail", @navigateMail, @
        @on "update_number_mails_shown", @calculateMailsShown, @
        setInterval @fetchNew, 1000 * 15

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
        mails = window.app.mails
        @url = "mailslist/" + mails.timestampOld + "." + mails.mailsAtOnce + "/" + mails.lastIdOld
        @fetch
            add: true
            success: callback
            error: errorCallback

    # fetches new mails from server
    fetchNew: (callback, errorCallback) ->
        mails = window.app.mails
        mails.url = "mails/new/" + mails.timestampNew + "/" + mails.lastIdNew
        mails.fetch
            add: true
            success: callback
            error: errorCallback
