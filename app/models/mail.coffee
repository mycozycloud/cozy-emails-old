fs = require 'fs'
async = require 'async'

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
            mail_id: @id
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
