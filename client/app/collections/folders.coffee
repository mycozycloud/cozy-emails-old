class exports.FolderCollection extends Backbone.Collection
    model: require('models/folder').Folder
    url: 'folders'