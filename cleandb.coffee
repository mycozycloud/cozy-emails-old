server = require './server'

# Small script to remove all data for Cozy mails.

Mail.destroyAll ->
    MailToBe.destroyAll ->
        Attachment.destroyAll ->
            Mailbox.destroyAll ->
                process.exit(0)
