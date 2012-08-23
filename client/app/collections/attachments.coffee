{Attachment} = require "../models/attachment"

###


###
class exports.AttachmentsCollection extends Backbone.Collection
    
  model: Attachment
  url: 'getattachments'
  
  setModel: (@areAttachmentsOf) ->
    @url = 'getattachments/' + @areAttachmentsOf.get "id"
    @fetch()
  
  # comparator: (attachment) ->
    # attachment.get("name")