# Helpers

LogMessage.orderedByDate = (params, callback) ->
    callback = params if typeof(params) is "function"
    LogMessage.request "date", descending: true, callback

LogMessage.destroyAll = (params, callback) ->
     callback = params if typeof(params) is "function"
     LogMessage.requestDestroy "all", params, callback

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

LogMessage.createCheckhMailError = (mailbox, callback) ->
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
    attributes =
        type: "info"
        subtype: data.subtype
        text: data.text
        createdAt: new Date().valueOf()
        timeout: data.timeout
        counter: data.counter
    LogMessage.create attributes, callback


LogMessage.createImportInfo = (results, mailbox, callback) ->
    mail_text = "mail"
    mail_text += "s" if results.length > 1
    msg = "Downloading <strong>#{results.length}</strong> #{mail_text} from "
    msg += "<strong>#{mailbox.name}</strong> "
    
    data =
        subtype: "download"
        text: msg
        timeout: 5
        mailbox: mailbox.id
        counter: results.length

    LogMessage.orderedByDate limit: 1, (err, logMessages) ->
        callback err if err
        if logMessages.length > 0 and
        logMessages[0].subtype is data.subtype and
        logMessages[0].mailbox is data.mailbox
            logMessage = logMessages[0]
            logMessage.createdAt = new Date().valueOf()
            logMessage.counter += results.length
            
            msg = "Downloading <strong>#{logMessage.counter}</strong>"
            msg += " #{mail_text} from "
            logMessage.save callback
        else
            LogMessage.createInfo data, callback

LogMessage.createNewMailInfo = (mailbox, callback) ->
    msg = "Check for new mail in <strong>#{mailbox.name}</strong> finished at "
    msg += new Date().toUTCString()
    data =
        subtype: "check"
        text: msg
        timeout: 5
        mailbox: mailbox.id
    LogMessage.createInfo data, callback

LogMessage.createImportStartedInfo = (mailbox, callback) ->
    data =
        subtype: "start"
        text: "Import of <strong>" + mailbox.name + "</strong> started."
        timeout: 5
        mailbox: mailbox.id
    LogMessage.createInfo data, callback

LogMessage.createBoxProgressInfo = (mailbox, progress, callback) ->
    data =
        type: "info",
        subtype: "progress"
        text: "Import of <strong>" + mailbox.name + "</strong> " + progress + "% complete",
        createdAt: new Date().valueOf(),
        timeout: 10
        mailbox: mailbox.id
    LogMessage.create data, callback


# Success

LogMessage.createImportSuccess = (mailbox, callback) ->
    data =
        type: "success"
        subtype: "end"
        text: "Import of <strong>" + mailbox.name + "</strong> complete !"
        createdAt: new Date().valueOf()
        timeout: 5
        mailbox: mailbox.id
    LogMessage.create data, callback
