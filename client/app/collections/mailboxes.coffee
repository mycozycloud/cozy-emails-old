{Mailbox} = require "../models/mailbox"

###
    @file: mailboxes.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Generic collection of all mailboxes configured by user.
        Uses standard "resourceful" approach for DB API, via it's url.

###
class exports.MailboxCollection extends Backbone.Collection
        
    model: Mailbox
    url: 'mailboxes/'
    activeMailboxes: []
    
    initialize: ->
        @on 'add', @addView, @

    comparator: (mailbox) ->
        mailbox.get 'name'
        
    addView: (mail) ->
        @view.addOne mail if @view?
    
    # function fired when user changes the set of active mailboxes 
    # to rerender the list (filter it)
    updateActiveMailboxes: ->
        @activeMailboxes = []
        @each (mailbox) =>
            if mailbox.get 'checked'
                @activeMailboxes.push mailbox.get('id')
        
        @trigger 'change_active_mailboxes', @
