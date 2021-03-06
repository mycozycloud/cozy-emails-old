Mailbox = require '../models/mailbox'

# Check if some mailboxes should were importing during last app shutdown.
# If it is the case, it starts the import again.
module.exports = ->

    importBox = (box) ->
        box.fullImport()

    Mailbox.all (err, boxes) ->
        if err
            console.log err
            console.log "Something went wrong while checking mailboxes"
        else
            for box in boxes
                if box.status is "import_preparing"
                    box.log "start again import from scracth"
                    box.reset (err) =>
                        if err
                            box.log err
                        else
                            importBox box
                else if box.status in ["import_failed", "importing", "freezed"]
                    box.reset (err) =>
                        if err
                            box.log err
                        else
                            importBox box
                else
                    box.log "status #{box.status}"
                    box.log "already imported"
