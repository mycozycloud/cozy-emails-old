# Errors

LogMessage.createError = (data, callback) ->
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

LogMessage.createCheckhMailError = (mailbox, callback) ->
    msg =  "Checking for new mail of <strong>#{mailbox.name}</strong> failed. "
    msg += "Please verify its settings."
    data =
        subtype: "check"
        text: msg
    LogMessage.createError data, callback

LogMessage.createImportPreparationError = (mailbox, callback) ->
    msg =  "Could not prepare the import of <strong>#{mailbox.name}</strong>. "
    msg += "Please verify its settings."
    data =
        subtype: "preparation"
        text: msg
    LogMessage.createError data, callback

LogMessage.createBoxImportError = (mailbox, callback) ->
    msg = "Import of <strong>#{mailbox.name}</strong> failed. "
    msg += "Please verify its settings.",
    data =
        subtype: "boximport"
        text: msg
    LogMessage.createError data, callback


# Notifications

LogMessage.createInfo = (data, callback) ->
    attributes =
        type: "info"
        subtype: data.subtype
        text: data.text
        createdAt: new Date().valueOf()
        timeout: data.timeout
    LogMessage.create attributes, callback

LogMessage.createImportInfo = (results, mailbox, callback) ->
    mail_text = "mail"
    mail_text += "s" if results.length > 1
    msg = "Downloading <strong>#{results.length}</strong> #{mail_text} from "
    msg += "<strong>#{mailbox.name}</strong> "
    
    data
        subtype: "download"
        text: msg
        timeout: 5
    LogMessage.createInfo data, callback

LogMessage.createNewMailInfo = (mailbox, callback) ->
    msg = "Check for new mail in <strong>#{mailbox.name}</strong> finished at "
    msg += new Date().toUTCString()
    data =
        subtype: "check"
        text: msg
        timeout: 5
    LogMessage.createInfo data, callback

LogMessage.createImportStartedInfo = (mailbox, callback) ->
    data =
        subtype: "start"
        text: "Import of <strong>" + mailbox.name + "</strong> started."
        timeout: 5
    LogMessage.createInfo data, callback

LogMessage.createBoxProgressInfo = (mailbox, progress, callback) ->
    data =
        type: "info",
        subtype: "progress"
        text: "Import of <strong>" + mailbox.name + "</strong> " + progress + "% complete",
        createdAt: new Date().valueOf(),
        timeout: 10
    LogMessage.create data, callback


# Success

LogMessage.createImportSuccess = (mailbox, callback) ->
    data =
        type: "success"
        subtype: "end"
        text: "Import of <strong>" + mailbox.name + "</strong> complete !"
        createdAt: new Date().valueOf()
        timeout: 5
    LogMessage.create data, callback
