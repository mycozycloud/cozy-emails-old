{Mailbox} = require "models/mailbox"
ViewCollection = require 'lib/view_collection'

###
    @file: mailboxes_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Displays the list of configured mailboxes.
###

class exports.MailboxesList extends ViewCollection

    id: "mailboxes"
    itemView: require('views/mailboxes_list_element')
    template: require('templates/_mailbox/list')

    checkIfEmpty: ->
        super
        @$('#no-mailbox-msg').toggle(_.size(@views) is 0)

    appendView: (view) ->
        @$el.prepend view.$el

    afterRender: ->
        super
        @$el.niceScroll()

    activate: (id) ->
        for cid, view of @views
            if view.model.id is id then view.$el.addClass 'active'
            else view.$el.removeClass 'active'
