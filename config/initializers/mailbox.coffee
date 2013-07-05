requests = require "../../common/requests"

# Check if some mailboxes should were importing during last app shutdown.
# If it is the case, it starts the import again.
module.exports = (compound) ->
    {Mailbox} = compound.models

    Mailbox.all (err, boxes) ->
        if err
            console.log err
            console.log "Something went wrong while checking mailboxes"
            return

        for box in boxes
            switch box.status
                when "import_preparing"
                    box.log "start again import from scracth"
                    box.destroyMailsToBe (err) =>
                        if err then box.log err
                        else box.fullImport()

                when "import_failed"
                    box.destroyMailsToBe (err) =>
                        box.destroyMails (err) =>
                            box.fullImport()

                when "importing", "freezed"
                    box.log "try to finish the import"
                    box.fullImport()

                else
                    box.log "status #{box.status}"
                    box.log "already imported"
