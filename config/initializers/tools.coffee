module.exports = (compound) ->
    app = compound.app

    compound.tools.database = ->
        {Mail, MailFolder, MailSent, Mailbox, LogMessage} = compound.models

        switch process.argv[3]
            when 'cleandb'
                Mail.destroyAll ->
                    MailSent.destroyAll ->
                        MailFolder.destroyAll ->
                            MailSent.destroyAll ->
                                Mailbox.destroyAll ->
                                    console.log 'All data cleaned'
                                    process.exit 0
                break
            else
                console.log 'Usage: compound database [cleandb]'
