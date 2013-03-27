module.exports = (compound, Attachment) ->
    Attachment.fromMail = (params, callback) ->
        Attachment.request "byMail", params, callback

    Attachment.fromMailbox = (params, callback) ->
        Attachment.request "byMailbox", params, callback
