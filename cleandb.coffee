server = require './server'

# Small script to remove all data for Cozy mails.

Mail.destroyAll ->
    MailToBe.destroyAll ->
        MailSent.destroyAll ->
            Attachment.destroyAll ->
                Mailbox.destroyAll ->
                    LogMessage.destroyAll ->
                        process.exit(0)
