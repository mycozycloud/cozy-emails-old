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

    appendView: (view) =>
        if @currentMailbox isnt view.model.get 'mailbox'
            @currentMailbox = view.model.get 'mailbox'
            console.log app.mailboxes.length, @currentMailbox
            title = app.mailboxes.get(@currentMailbox).get 'name'
            @$('#folderlist').append "<li class='nav-header'>#{title}</li>"

        @$('#folderlist').append view.$el
