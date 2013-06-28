###
    @file: menu_mailboxes_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The element of the list of mailboxes in the leftmost column - the menu.

###

class exports.MenuMailboxListElement extends Backbone.View
    tagName: 'li'

    constructor: (@model, @collection) ->
        super()

    events:
        'click a.menu_choose' : 'setupMailbox'

    setupMailbox: (event) ->
        @model.set 'checked', not @model.get('checked')
        @model.save()
        @collection.updateActiveMailboxes()

    render: ->
        template = require('templates/_mailbox/mailbox_menu')
        @$el.html template model: @model.toJSON()
        @
