# Errors

LogMessage.createImportError = (error, callback) ->
    data =
        type: "error"
        subtype: "import"
        tex: "Error importing mail: " + error.toString()
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createCheckhMailError = (mailboxn, callback) ->
    data =
        type: "error",
        subtype: "check"
        text: "Checking for new mail of <strong>" + mailbox.name + "</strong> failed. Please verify its settings."
        createdAt: new Date().valueOf()
        timeout: 3600
    LogMessage.create data, callback

LogMessage.createImportPreparationError = (mailbox, callback) ->
    data =
        type: "error",
        subtype: "preparation"
        text: "Could not prepare the import of <strong>" + mailbox.name + "</strong>. Please verify its settings."
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createBoxImportError = (error, callback) ->
    data =
        type: "error",
        subtype: "boximport"
        text: "Import of <strong>" + mailbox.name + "</strong> failed. Please verify its settings.",
        createdAt: new Date().valueOf(),
        timeout: 0
    LogMessage.create data, callback


# Notifications

LogMessage.createImportInfo = (results, mailbox, callback) ->
    mail_text = "mail"
    mail_text += "s" if results.length > 1
    
    data
        type: "info"
        subtype: "download"
        text: "Downloading <strong>" + results.length + "</strong> " + mail_text + " from <strong>" + mailbox.name + "</strong> "
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createNewMailInfo = (mailbox, callback) ->
    data =
        type: "info"
        subtype: "check"
        text: "Check for new mail in <strong>" + mailbox.name + "</strong> finished at " + new Date().toUTCString()
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createImportStartedInfo = (mailbox, callback) ->
    data =
        type: "info"
        subtype: "start"
        text: "Import of <strong>" + mailbox.name + "</strong> started."
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createImportEndedInfo = (mailbox, callback) ->
    data =
        type: "success"
        subtype: "end"
        text: "Import of <strong>" + mailbox.name + "</strong> complete !"
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback

LogMessage.createBoxProgressInfo = (mailbox, progress, callback) ->
    data =
        type: "info",
        subtype: "progress"
        text: "Import of <strong>" + mailbox.name + "</strong> " + progress + "% complete",
        createdAt: new Date().valueOf(),
        timeout: 10
    LogMessage.create data, callback
