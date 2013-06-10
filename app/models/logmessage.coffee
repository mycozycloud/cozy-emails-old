
module.exports = (compound, LogMessage) ->
    # Helpers

    NotificationHelper = require('cozy-notifications-helper')
    Notifications = new NotificationHelper('mails')

    LogMessage.orderedByDate = (params, callback) ->
        if typeof(params) is "function"
            callback = params
            params = descending: true
        else
            params.descending = true
        LogMessage.request "date", params, callback

    # Errors

    # todo: update date if error is still present
    LogMessage.createError = (data, callback) ->
        LogMessage.orderedByDate limit: 1, (err, logMessages) ->
            callback err if err

            if logMessages.length > 0 and
            logMessages[0].subtype is data.subtype and
            logMessages[0].mailbox is data.mailbox

                logMessages[0].createdAt = new Date().valueOf()
                logMessages[0].save callback
            else
                attributes =
                    type: "error"
                    subtype: data.subtype
                    text: data.text
                    createdAt: new Date().valueOf()
                    timeout: 0
                LogMessage.create attributes, callback

    LogMessage.createImportError = (error, callback) ->
        data =
            subtype: "import"
            text: "Error importing mail: #{error.toString()}"
        LogMessage.createError data, callback

    LogMessage.createCheckMailError = (mailbox, callback) ->
        msg =  "Checking for new mail of <strong>#{mailbox.name}</strong> failed. "
        msg += "Please verify its settings."
        data =
            subtype: "check"
            text: msg
            mailbox: mailbox.id
        LogMessage.createError data, callback

    LogMessage.createImportPreparationError = (mailbox, callback) ->
        msg =  "Could not prepare the import of <strong>#{mailbox.name}</strong>. "
        msg += "Please verify its settings."
        data =
            subtype: "preparation"
            text: msg
            mailbox: mailbox.id
        LogMessage.createError data, callback

    LogMessage.createBoxImportError = (mailbox, callback) ->
        msg = "Import of <strong>#{mailbox.name}</strong> failed. "
        msg += "Please verify its settings."
        data =
            subtype: "boximport"
            text: msg
            mailbox: mailbox.id
        LogMessage.createError data, callback


    # Notifications

    LogMessage.createInfo = (data, callback) ->
        data.type = "info"
        data.createdAt = new Date().valueOf()

        LogMessage.create data, callback


    LogMessage.createImportInfo = (results, mailbox, callback) ->
        mail_text = "mail"
        mail_text += "s" if results.length > 1
        msg = "Downloading #{results.length} #{mail_text} from #{mailbox.name}"

        Notifications.createOrUpdatePersistent "download-#{mailbox.id}",
            text: msg
            resource:
                app: 'mails'
                url: 'mail/#{results[0].id}'

        callback()

    LogMessage.createNewMailInfo = (mailbox, nbNewMails, callback) ->
        return callback() if nbNewMails is 0

        mail_text = "mail"
        mail_text += "s" if nbNewMails > 1
        msg = "#{nbNewMails} new #{mail_text} in #{mailbox.name}"

        Notifications.createOrUpdatePersistent 'newmail-#{mailbox.id}',
            text: msg
            msg = "#{nbNewMails} new mail"
            msg += "s" if nbNewMails > 1
            msg += " in #{mailbox.name}"

        callback()

    LogMessage.createImportStartedInfo = (mailbox, callback) ->

        Notifications.createOrUpdatePersistent "importprogress-#{mailbox.id}",
            text: "Import of #{mailbox.name} started."
            resource:
                app: 'mails'
                url: 'config-mailboxes'

        callback()

    LogMessage.createImportProgressInfo = (mailbox, progress, callback) ->

        Notifications.createOrUpdatePersistent "importprogress-#{mailbox.id}",
            text: "Import of #{mailbox.name} : #{progress}% complete"
            resource:
                app: 'mails'
                url: 'config-mailboxes'

        callback()

    # Success

    LogMessage.createImportSuccess = (mailbox, callback) ->

        Notifications.createOrUpdatePersistent "importprogress-#{mailbox.id}",
            text: "Import of #{mailbox.name} is complete !"
            resource:
                app: 'mails'
                url: ''

        callback()
