requests = require "../../common/requests"

## Requests required to query couchdb documents

# Mails
mailboxRequest = -> emit doc.mailbox, doc
dateRequest = -> emit [doc.dateValueOf, doc._id], doc

mailboxDateRequest = -> emit [doc.mailbox, doc.dateValueOf], doc

Mail.fromMailbox = (params, callback) ->
    Mail.request "mailboxDate", params, callback
Mail.date = (params, callback) -> Mail.request "date", params, callback
Mail.defineRequest "all", requests.all, ->
    Mail.defineRequest "date", dateRequest, ->
        Mail.defineRequest "mailboxDate", mailboxDateRequest, ->
            Mail.defineRequest "mailbox", mailboxRequest, requests.checkError
        
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
dateRequest = -> emit doc.createdAt, doc
LogMessage.defineRequest "all", requests.all, ->
    LogMessage.defineRequest "date", dateRequest, requests.checkError