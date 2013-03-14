fs = require 'fs'
async = require 'async'

Mail.fromMailbox = (params, callback) ->
    Mail.request "byMailbox", params, callback

Mail.dateId = (params, callback) ->
    Mail.request "dateId", params, callback

Mail.fromMailboxByDate = (params, callback) ->
    Mail.request "dateByMailbox", params, callback


# Get attachments returned by mailparser as parameter. Save them as couchdb
# attachments wrapped in a dedicated model.
Mail::saveAttachments = (attachments, callback) ->

    if attachments? and attachments.length > 0
        attachment = attachments.pop()
        params =
            cid: attachment.contentId
            fileName: attachment.fileName
            contentType: attachment.contentType
            length: attachment.length
            mailId: @id
            checksum: attachment.checksum
            mailbox: @mailbox
        Attachment.create params, (error, attach) =>
            fileName =  "/tmp/#{attachment.fileName}"
            fs.writeFile fileName, attachment.content, (error) =>
                attach.attachFile fileName, (error) =>
                    fs.unlink fileName, (error) =>
                        @saveAttachments attachments, callback
    else
        callback()


# Update mail attributes with given flags. Save model if changes occured.
Mail::updateFlags = (flags, callback) ->
    seen = '\\Seen' in flags
    flagged = '\\Flagged' in flags
    @flags = flags

    isModification = false
    if @read isnt seen
        @read = seen
        isModification = true
    
    if @flagged isnt flagged
        @flagged = flagged
        isModification = true
   
    if isModification
        @save callback
    else


# Get attachments returned by mailparser as parameter. Save them as couchdb
# attachments wrapped in a dedicated model.
Mail::saveAttachments = (attachments, callback) ->

    if attachments? and attachments.length > 0
        attachment = attachments.pop()
        params =
            cid: attachment.contentId
            fileName: attachment.fileName
            contentType: attachment.contentType
            length: attachment.length
            mailId: @id
            checksum: attachment.checksum
            mailbox: @mailbox
        Attachment.create params, (error, attach) =>
            fileName =  "/tmp/#{attachment.fileName}"
            fs.writeFile fileName, attachment.content, (error) =>
                attach.attachFile fileName, (error) =>
                    fs.unlink fileName, (error) =>
                        @saveAttachments attachments, callback
    else
        callback()


# Update mail attributes with given flags. Save model if changes occured.
Mail::updateFlags = (flags, callback) ->
    seen = '\\Seen' in flags
    flagged = '\\Flagged' in flags
    @flags = flags

    isModification = false
    if @read isnt seen
        @read = seen
        isModification = true
    
    if @flagged isnt flagged
        @flagged = flagged
        isModification = true
   
    if isModification
        @save callback
    else
        callback() if callback?
