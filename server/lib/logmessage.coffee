
NotificationHelper = require('cozy-notifications-helper')
Notifications = new NotificationHelper('mails')

module.exports = LogMessage = {}

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
    if nbNewMails is 0
        Notifications.destroy 'newmail-#{mailbox.id}'
        return callback()

    mail_text = "mail"
    mail_text += "s" if nbNewMails > 1
    msg = "#{nbNewMails} new #{mail_text} in #{mailbox.name}"

    Notifications.createOrUpdatePersistent 'newmail-#{mailbox.id}',
        text: msg

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

    callback?()

# Success

LogMessage.createImportSuccess = (mailbox, callback) ->

    Notifications.createOrUpdatePersistent "importprogress-#{mailbox.id}",
        text: "Import of #{mailbox.name} is complete !"
        resource:
            app: 'mails'
            url: ''

    callback()

LogMessage.createImportFailed = (mailbox, callback) ->

    Notifications.createOrUpdatePersistent "importprogress-#{mailbox.id}",
        text: "Import of #{mailbox.name} has failed !"
        resource:
            app: 'mails'
            url: ''

    callback()


LogMessage.destroy = (mailbox, callback) ->
    Notifications.destroy "newmail-#{mailbox.id}"
    Notifications.destroy "download-#{mailbox.id}"
    Notifications.destroy "importprogress-#{mailbox.id}"
    callback()
