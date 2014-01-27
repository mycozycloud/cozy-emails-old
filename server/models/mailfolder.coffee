async = require 'async'
americano = require 'americano-cozy'
queue = require '../lib/queue'

Email = require './email'

# MailFolder is a IMAP Mailbox, it contains mails.
module.exports = MailFolder = americano.getModel 'MailFolder',
    name: String
    path: String
    specialType: String
    mailbox: String
    imapLastFetchedId: {type: Number, default: 0}
    mailsToBe: Object

MailFolder::log = (msg) ->
    console.info "#{@} #{msg?.stack or msg}"

MailFolder::toString = ->
    "[Folder #{@name} #{@id} of Mailbox #{@mailbox}]"

MailFolder.findByMailbox = (mailboxid, callback) ->
    MailFolder.request "byMailbox", {key: mailboxid}, callback

MailFolder.byType = (type, callback) ->
    MailFolder.request "byType", {key: type}, callback


# Setup import: open box, fetch ids to download
# and store them in folders mailToBe field
MailFolder::setupImport = (getter, callback) ->

    path = if @specialType is 'INBOX' then 'INBOX' else @path

    getter.openBox path, (err) =>
        return callback err if err

        abort = (msg, err) =>
            @log msg
            @log err.stack if err
            getter.closeBox -> callback err

        getter.getAllMails (err, results) =>
            return abort "Can't retrieve emails", err if err

            @log "Search query succeeded"

            return abort "No message to fetch" if results.length is 0

            @log "#{results.length} mails to download"
            @log "Start grabing mail ids"

            maxId = 0

            ids = []
            for id in results
                id = parseInt id
                maxId = id if id > maxId
                ids.push id

            data =
                mailsToBe: ids
                imapLastFetchedId: maxId

            @updateAttributes data, (err) =>
                return abort "can't save folder state", err if err

                @log "Finished saving ids to database"
                @log "max id = #{maxId}"
                @log "folder #{@name} setup is done"

                getter.closeBox callback

# do the actual import
# fetch mailToBe one by one
MailFolder::pushFetchTasks = (getter) ->

    # If folder is empty of remote mails, no action will be performed.
    if not @mailsToBe? or @mailsToBe.length is 0
        @log "Import: Nothing to download"
        return 0
    else
        @log "Import: #{@mailsToBe.length} mails to fetch"

    # TODO : delete all mails from this folder, in case the import failed
    path = if @specialType is 'INBOX' then 'INBOX' else @path

    @done       = 0
    @total      = @mailsToBe.length
    @success    = 0
    @oldpercent = 0

    id = @id

    @queue = queue()
    folder = @
    for mailToBe in @mailsToBe
        getJob = (folder, getter, remoteId, progress) ->
            (queue, done) ->
                getter.fetchMail remoteId, (err, mail, attachments) =>
                    mail.folder = folder.id

                    Email.create mail, (err, mail) =>
                        return done err if err

                        msg =  "New mail created: #{mail.idRemoteMailbox}"
                        msg += " #{mail.id} [#{mail.subject}] "
                        msg += JSON.stringify mail.from
                        folder.log msg

                        mail.saveAttachments attachments, (err) ->
                            folder.done++
                            if err
                                folder.log 'Mail creation error, skip this mail'
                                console.log err
                                done() # do not pass error to keep looping
                            else
                                queue.emit 'success'
                                folder.success++
                                folder.log "Imported #{folder.done}/#{folder.total} (#{folder.success} ok)"
                                done()

        @queue.push getJob(folder, getter, mailToBe)

        , false
    return @queue


# Get message corresponding to given remote ID, save it to database and
# download its attachments.
MailFolder::fetchMessage = (getter, remoteId, callback) ->

    getter.fetchMail remoteId, (err, mail, attachments) =>

        mail.folder = @id

        Email.create mail, (err, mail) =>
            return callback err if err

            msg = "New mail created: #{mail.idRemoteMailbox}"
            msg += " #{mail.id} [#{mail.subject}] "
            msg += JSON.stringify mail.from
            @log msg

            mail.saveAttachments attachments, (err) ->
                callback err, mail


# Check if new mails arrives in remote inbox (base this on the last email
# fetched id). Then it synchronize last recieved mails.
MailFolder::getNewMails = (getter, limit, callback) ->

    id = Number(@imapLastFetchedId) + 1
    range = "#{id}:#{id + limit}"
    @log "Fetching new mails: #{range}"

    path = if @specialType is 'INBOX' then 'INBOX' else @path

    getter.openBox path, (err) =>
        return callback err if err

        error = (err) =>
            getter.closeBox (err) =>
                @log err
                callback err

        success = (nbNewMails) =>
            getter.closeBox (err) =>
                @log err
                callback null, nbNewMails

        getter.getMails range, (err, results) =>
            return error err if err

            maxId = id - 1

            results = [] unless results

            async.eachSeries results, (remoteId, callback) =>

                @log "fetching mail : #{remoteId}"
                @fetchMessage getter, remoteId, (err, mail) =>
                    return callback err if err

                    maxId = remoteId if remoteId > maxId
                    callback null

            , (getMailsErr) =>

                # maxId is the last successful id
                if maxId isnt id - 1

                    @updateAttributes imapLastFetchedId: maxId, (err) =>

                        return error err         if err
                        return error getMailsErr if err

                        @synchronizeChanges getter, limit, (err) =>
                            @log err if err
                            return success results.length

                else
                    @synchronizeChanges getter, limit, (err) =>
                        @log err if err
                        return success results.length


# Get last changes from remote inbox (defined by limit, get the limit latest
# mails...) and update the current mailbox mails if needed.
# Changes are based upon flags. If a mail has no flag it is considered as
# deleted. Else it updates read and starred status if they change.
# Called when the user hit refresh, so --theirs strategy
MailFolder::synchronizeChanges = (getter, limit, callback) ->
    getter.getLastFlags this, limit, (err, flagDict) =>
        return callback err if err
        query =
            startkey: [@id, {}]
            endkey: [@id]
            limit: limit
            descending: true

        Email.fromFolderByDate query, (err, mails) =>
            return callback err if err
            for mail in mails
                flags = flagDict[mail.idRemoteMailbox]

                if flags?
                    mail.updateFlags flags

            callback()

# Synchronize 1 mail's flags with the IMAP server.
# Called when the model just have been modified in cozy-mail
# so fix conflicts with --ours strategy
MailFolder::syncOneMail = (getter, mail, newflags, callback) ->

    @log "Add read flag to mail #{mail.idRemoteMailbox}"
    return unless mail.changedFlags newflags

    path = if @specialType is 'INBOX' then 'INBOX' else @path

    getter.openBox path, (err) =>
        @log err if err
        return callback err if err

        getter.setFlags mail, newflags, (err) =>

            getter.closeBox (e) =>

                unless err
                    @log "mail #{mail.idRemoteMailbox} marked as seen"
                    mail.updateAttributes flags: newflags, callback
