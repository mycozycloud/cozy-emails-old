requests = require "../../common/requests"

module.exports = (compound) ->
    {Mail, Mailbox, MailToBe, LogMessage, Attachment} = compound.models

    ## Requests required to query couchdb documents


    # Mails
    mailboxRequest = -> emit doc.mailbox, doc
    dateIdRequest = -> emit [doc.dateValueOf, doc._id], doc
    dateRequest = -> emit doc.dateValueOf, doc
    dateMailboxRequest = -> emit [doc.mailbox, doc.dateValueOf], doc

    Mail.defineRequest "all", requests.all, requests.checkError
    Mail.defineRequest "date", dateRequest, requests.checkError
    Mail.defineRequest "dateId", dateIdRequest, requests.checkError
    Mail.defineRequest "byMailbox", mailboxRequest, requests.checkError
    Mail.defineRequest "dateByMailbox", dateMailboxRequest, requests.checkError


    # Attachments
    mailRequest = -> emit doc.mailId, doc
    mailboxRequest = -> emit doc.mailbox, doc

    Attachment.defineRequest "all", requests.all, requests.checkError
    Attachment.defineRequest "byMail", mailRequest, requests.checkError
    Attachment.defineRequest "byMailbox", mailboxRequest, requests.checkError


    # MailToBe
    mailboxRequest = -> emit [doc.mailbox, doc.remoteId], doc

    MailToBe.defineRequest "all", requests.all, requests.checkError
    MailToBe.defineRequest "byMailbox", mailboxRequest, requests.checkError


    # Mailboxes
    byEmailRequest = -> emit doc.login, doc
    Mailbox.defineRequest "all", requests.all, requests.checkError
    Mailbox.defineRequest "byEmail", byEmailRequest, requests.checkError


    # Log messages
    dateRequestLog = -> emit doc.createdAt, doc

    LogMessage.defineRequest "all", requests.all, requests.checkError
    LogMessage.defineRequest "date", dateRequestLog, requests.checkError


    # Mails Sent
    #dateRequestSent = -> emit doc.createdAt, doc
    #dateIdRequestSent = -> emit [doc.createdAt, doc._id], doc

    #MailSent.defineRequest "all", requests.all, requests.checkError
    #MailSent.defineRequest "date", dateRequestSent, requests.checkError
    #MailSent.defineRequest "dateId", dateIdRequestSent, requests.checkError
