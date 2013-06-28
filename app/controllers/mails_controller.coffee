###
    @file: mails_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller to handle mails CRUD backend and their attachments.
###


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

, { only: ['show', 'update', 'destroy', 'getattachmentslist'] }


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



action 'byFolder', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp

    query =
        startkey: [req.params.folderId, {}]
        endkey: [req.params.folderId]
        limit: num
        descending: true

    Mail.request 'folderDate', query, (err, mails) ->
        return handle err if err
        send mails



# GET '/mails/:timestamp/:num'
# Get num mails until given timestamp.
action 'getlist', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp

    # skip = params.id? and params.id isnt "undefined"

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        # skip: if skip then 1 else 0

    Mail.dateId query, (err, mails) ->
        return handle err if err

        mails = [] if mails.length is 0 # ?
        send mails


# # GET '/mailsnew/:timestamp'
# # Get all mails after a given timestamp.
# action 'getnewlist', ->
#     timestamp = parseInt params.timestamp

#     query =
#         startkey: [timestamp, undefined]
#         descending: false
#         skip: 1

#     Mail.dateId query, (err, mails) ->
#         return handle err if err
#         send mails

# GET '/mails/:id/attachments
# Get all attachements object for given mail.
action 'getattachmentslist', ->
    query = key: @mail.id

    Attachment.fromMail query, (err, attachments) ->
        return handle err if err
        send attachments

# GET '/attachments/:id/'
# Get file linked to attachement with given id.
action 'getattachment', ->
    Attachment.find params.id, (err, attachment) =>
        return handle err              if err
        return handle 'not found', 400 if not attachment

        stream = attachment.getFile attachment.fileName, (err, res, body) ->

            return handle err if err or not res or res.statusCode isnt 200
            return handle 'File not found', 404 if res.statusCode is 404

            send success: true, 200

        stream.pipe res
