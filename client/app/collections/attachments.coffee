{Attachment} = require "../models/attachment"

###
    @file: attachments.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Backbone collection for handling Attachment objects.
        Used to render the list of attachments fetched for the chosen mail.
###

class exports.AttachmentsCollection extends Backbone.Collection
        
    model: Attachment
    
    constructor: (@mail) ->
        @url = "mails/#{@mail.get "id"}/attachments"
        super()
    
    comparator: (attachment) ->
        attachment.get "fileName"
