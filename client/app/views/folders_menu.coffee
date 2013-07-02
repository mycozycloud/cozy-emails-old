ViewCollection = require 'lib/view_collection'

###
    @file: mailboxes_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Displays the list of configured mailboxes.
###

module.exports = class FolderMenu extends ViewCollection

    id:        "folders-menu"
    tagName:   "div"
    className: "btn-group"
    itemView:  require 'views/folders_menu_element'
    template:  require 'templates/folders_menu'

    initialize: =>
        super
        @currentMailbox = ''

    checkIfEmpty: ->
        @$el.toggle _.size(@views) isnt 0

    appendView: (view) =>
        if @currentMailbox isnt view.model.get 'mailbox'
            @currentMailbox = view.model.get 'mailbox'
            title = app.mailboxes.get(@currentMailbox).get 'name'
            @$('#folderlist').append "<li class='nav-header'>#{title}</li>"

        @$('#folderlist').append view.$el
