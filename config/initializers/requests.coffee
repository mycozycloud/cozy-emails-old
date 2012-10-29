requests = require "../../common/requests"

## Requests required to query couchdb documents

# Mails
mailboxRequest = -> emit doc.mailbox, doc
dateIdRequest = -> emit [doc.dateValueOf, doc._id], doc
dateRequest = -> emit doc.dateValueOf, doc

Mail.defineRequest "all", requests.all, ->
    Mail.defineRequest "date", dateRequest, ->
        Mail.defineRequest "dateId", dateIdRequest, ->
            Mail.defineRequest "mailbox", mailboxRequest, requests.checkError

Mail.fromMailbox = (params, callback) ->
    Mail.request "mailboxDate", params, callback
Mail.dateId = (params, callback) ->
    Mail.request "dateId", params, callback
        
# MailToBe
mailboxRequest = -> emit [doc.mailbox, doc.remoteId], doc

MailToBe.defineRequest "all", requests.all, ->
    MailToBe.defineRequest "byMailbox", mailboxRequest, requests.checkError

MailToBe.fromMailbox = (mailbox, callback) ->
    params =
        startkey: [mailbox.id + "0"]
        endkey: [mailbox.id]
        descending: true
    
    MailToBe.request "byMailbox", params, callback

# Mailboxes
Mailbox.defineRequest "all", requests.all, requests.checkError

# Attachments
mailRequest = -> emit doc.mail_id, doc
Attachment.defineRequest "byMail", mailRequest, requests.checkError
Attachment.fromMail = (params, callback) ->
    Mailbox.request "byMail", params, callback

#logmessage
dateRequestLog = -> emit doc.createdAt, doc
LogMessage.defineRequest "all", requests.all, ->
    LogMessage.defineRequest "date", dateRequestLog, requests.checkError