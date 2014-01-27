fs = require 'fs'
async = require 'async'
EmailGetter = require '../lib/mail_getter'
americano = require 'americano-cozy'

module.exports = Email = americano.getModel 'Email',
    mailbox: String
    folder: String
    idRemoteEmailbox: String
    remoteUID: String
    createdAt: {type: Number, default: 0}
    dateValueOf: {type: Number, default: 0}
    date: {type: Date, default: 0}
    headersRaw: String
    raw: String
    priority: String
    subject: String
    from: String
    to: String
    cc: String
    text: String
    html: String
    flags: Object
    read: {type: Boolean, default: false}
    flagged: {type: Boolean, default: false}
    hasAttachments: {type: Boolean, default: false}
    inReplyTo: String
    references: String
    _attachments: Object



Email.fromMailbox = (params, callback) ->
    Email.request "byMailbox", params, callback

Email.dateId = (params, callback) ->
    Email.request "dateId", params, callback

Email.fromMailboxByDate = (params, callback) ->
    Email.request "dateByMailbox", params, callback

Email.fromFolderByDate = (params, callback) ->
    Email.request 'folderDate', params, callback

# Get attachments returned by mailparser as parameter.
# Save them as couchdb attachments.
Email::saveAttachments = (attachments, callback) ->

    return callback null unless attachments? and attachments.length > 0

    async.each attachments, (attachment, callback) =>

        params =
            cid:         attachment.contentId or 'null'
            fileName:    attachment.fileName
            contentType: attachment.contentType or ''
            length:      attachment.length or 0
            checksum:    attachment.checksum or ''
            mailbox:     @mailbox
            mailId:      @id

        fileName =  "/tmp/#{attachment.fileName}"
        fs.writeFile fileName, attachment.content, (err) =>
            return callback err if err
            @attachFile fileName, params, (error) =>
                console.log error if error

                fs.unlink fileName, (err) =>
                    console.log err if err
                    callback(error or err)

    , (err) =>
        console.log err if err
        callback err


Email::remove = (getter, callback) ->

    getter.addFlags @idRemoteEmailbox, ['\\Deleted'], (err) ->
        return callback err if err

        @destroy callback


Email::updateAndSync = (attributes, callback) ->

    needSync = @changedFlags attributes.flags

    @updateAttributes attributes, (err) =>
        return callback err if err

        if needSync then @sync callback
        else callback null


Email::changedFlags = (newflags) ->
    oldseen    = '\\Seen'    in @flags
    oldflagged = '\\Flagged' in @flags

    newseen    = '\\Seen'    in newflags
    newflagged = '\\Flagged' in newflags

    oldseen isnt newseen or oldflagged isnt newflagged


# Update mail attributes with given flags. Save model if changes occured.
Email::updateFlags = (flags, callback=->) ->
    if @changedFlags flags
        @updateAttributes flags: flags, callback
    else
        callback null


Email::toString = (callback) ->
    "mail: #{@mailbox} #{@id}"
