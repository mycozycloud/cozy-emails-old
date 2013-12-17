BaseView = require 'lib/base_view'

module.exports = class FolderMenuElement extends BaseView

    tagName: 'li'
    template: (attributes) ->
        {id, name} = attributes
        "<a href=\"#folder/#{id}\"> #{name} </a>"

    getRenderData: -> @model.toJSON()