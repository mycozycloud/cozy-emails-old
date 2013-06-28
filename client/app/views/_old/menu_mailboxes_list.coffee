{MenuMailboxListElement} = require "./menu_mailboxes_list_element"

###
    @file: menu_mailboxes_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The list of mailboxes in the menu

###

class exports.MenuMailboxesList extends Backbone.View
    
    total_inbox: 0
    
    constructor: (@el, @collection) ->
        super()
        @collection.viewMenu_mailboxes = @
        @collection.on 'reset', @render, @
        @collection.on 'add', @render, @
        @collection.on 'remove', @render, @
        @collection.on 'change', @render, @

    render: ->
        @$el = $("#menu_mailboxes")
        @$el.html ""
        @total_inbox = 0
        for mailbox in @collection.toArray()
            box = new MenuMailboxListElement mailbox, @collection
            box.render()
            @$el.append box.el
            @total_inbox += (Number) mailbox.get("new_messages")
        @

    showLoading: ->
        @$el.html 'loading...'
        @$el.spin 'tiny'

    hideLoading: ->
        @$el.spin()
