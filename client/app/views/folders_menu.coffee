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

    appendView: (view) ->
        @$('#folderlist').append view.$el
