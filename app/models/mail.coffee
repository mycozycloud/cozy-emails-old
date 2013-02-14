fs = require 'fs'
async = require 'async'

# Get attachments returned by mailparser as parameter. Save them as couchdb
# attachments wrapped in a dedicated model.
Mail::saveAttachments = (attachments, callback) ->
    if attachments?
        attachFuncs = []

        for attachment in attachments
            params =
                cid: attachment.contentId
                fileName: attachment.fileName
                contentType: attachment.contentType
                length: attachment.length
                mail_id: @id
                checksum: attachment.checksum

            attachFunc = (callback) ->
                Attachment.create params, (error, attach) ->
                    fileName =  "/tmp/#{attachment.fileName}"
                    fs.writeFile fileName, attachment.content, ->
                        attach.attachFile fileName, callback
                            fs.unlink fileName, callback

            attachFuncs.push attachFunc

        async.series attachFuncs, callback
            
    else
        callback()
