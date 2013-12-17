
class exports.AttachmentsCollection extends Backbone.Collection
    comparator: 'filename'
    model: require 'models/attachment'