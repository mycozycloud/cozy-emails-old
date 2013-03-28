module.exports = (compound) ->
    app = compound.app
    
    compound.tools.database = ->
        {Mail, MailToBe, MailSent, Attachment, Mailbox, LogMessage} = \
            compound.models

        switch process.argv[3]
            when 'cleandb'
                Mail.destroyAll ->
                    MailToBe.destroyAll ->
                        MailSent.destroyAll ->
                            Attachment.destroyAll ->
                                Mailbox.destroyAll ->
                                    LogMessage.destroyAll ->
                                        console.log 'All data cleaned'
                                        process.exit 0
                break
            else
                console.log 'Usage: compound database [cleanuser|cleanapps]'
