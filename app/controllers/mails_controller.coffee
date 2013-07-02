###
    @file: mails_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller to handle mails CRUD backend and their attachments.
###

async = require('async')

handle = (err, code=500) ->
    console.log err.stack or err
    out = err.message or err or 'Server Error'
    send error: out, code

# shared functionnality : find the mail via its ID
before ->
    Mail.find params.id, (err, mail) =>
        return handle err if err
        return handle "not found" if not mail?

        @mail = mail
        next()

, { only: ['show', 'update', 'destroy', 'getattachmentslist', 'getattachment'] }


# GET /mails/:id
# Return mail corresponding to given ID.
action 'show', ->
    send @mail


# PUT /mails/:id
# Modify given mail. If mail read flag is changed, the remote mail version is
# updated too.
action 'update', ->
    markRead = false

    flagsChanged = @mail.changedFlags body.flags
    newflags = body.flags

    # flags will be updated after the sync on IMAP succeeds
    delete body.flags

    @mail.updateAttributes body, (err) =>
        return handle err if err
        return send success: true, 200 unless flagsChanged

        Mailbox.find @mail.mailbox, (err, mailbox) =>
            return handle err if err

            mailbox.syncOneMail @mail, newflags, (err) =>
                return handle err if err

                send success: true, 200

action 'destroy', ->

    Mailbox.find @mail.mailbox, (err, mailbox) =>
        return handle err if err

        mailbox.syncOneMail @mail, ["\\Deleted"], (err) =>
            return handle err if err

            @mail.destroy (err) =>
                return handle err if err

                send 204


# send num mails from folder id: folderId
# starting after timestamp
# descending order by date
action 'byFolder', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp

    # TODO use timestamp
    query =
        startkey: [req.params.folderId, {}]
        endkey: [req.params.folderId]
        limit: num
        descending: true

    Mail.fromFolderByDate query, (err, mails) ->
        return handle err if err
        send mails

# send num mails from the rainbow (merged INBOX folders)
# starting after timestamp
# descending order by date
action 'rainbow', ->
    limit = parseInt req.params.limit


    # get inboxes
    Folder.byType 'INBOX', (err, inboxes) ->
        return handle err if err
        outMails = []

        # forEach inbox
        async.each inboxes, (inbox, cb) ->

            query =
                startkey: [inbox.id, {}]
                endkey: [inbox.id]
                limit: limit
                descending: true

            # get num mails
            Mail.fromFolderByDate query, (err, mails) ->
                return cb err if err
                outMails.push mail for mail in mails
                cb null

        , (err) ->
            return handle err if err

            # sort by dateValueOf
            outMails.sort (a, b) -> return b.dateValueOf - a.dateValueOf

            # send only the 100 latest
            send outMails[0..99]


# # GET '/mails/:timestamp/:num'
# # Get num mails until given timestamp.
# action 'getlist', ->
#     num = parseInt req.params.num
#     timestamp = parseInt req.params.timestamp

#     # skip = params.id? and params.id isnt "undefined"

#     query =
#         startkey: [timestamp, params.id]
#         limit: num
#         descending: true
#         # skip: if skip then 1 else 0

#     Mail.dateId query, (err, mails) ->
#         return handle err if err

#         mails = [] if mails.length is 0 # ?
#         send mails


# # GET '/mails/:id/attachments
# # Get all attachements object for given mail.
# action 'getattachmentslist', ->
#     query = key: @mail.id

#     Attachment.fromMail query, (err, attachments) ->
#         return handle err if err
#         send attachments

# GET 'mails/:id/attachments/:filename'
# Get file linked to attachement with given id.
action 'getattachment', ->

    stream = @mail.getFile params.filename, (err, res, body) ->
        return handle err if err or not res or res.statusCode isnt 200
        return handle 'File not found', 404 if res.statusCode is 404

    stream.pipe res
