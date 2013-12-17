###
  @file: schema.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    Objects' descriptions.

###

# User defines user that can interact with the Cozy instance.
Mail = define 'Mail', ->
    property 'mailbox'
    property 'folder', Text
    property 'idRemoteMailbox',
    property 'remoteUID', Text
    property 'createdAt', Number, default: 0
    property 'dateValueOf', Number, default: 0
    property 'date', Date, default: 0
    property 'headersRaw', Text
    property 'raw', Text
    property 'priority',
    property 'subject',
    property 'from',
    property 'to',
    property 'cc',
    property 'text', Text
    property 'html', Text
    property 'flags', Object
    property 'read', Boolean, default: false
    property 'flagged', Boolean, default: false
    property 'hasAttachments', Boolean, default: false
    property 'inReplyTo'
    property 'references'
    property '_attachments'

MailSent = define 'MailSent', ->
    property 'mailbox'
    property 'createdAt', Number, default: 0
    property 'sentAt', Number, default: 0
    property 'subject',
    property 'from',
    property 'to',
    property 'cc',
    property 'bcc',
    property 'html', Text

# Mailbox object to store the information on connections to remote servers
# and have attached mails
Mailbox = define 'Mailbox', ->

    # identification
    property 'name'
    property 'config', Number, default: 0
    property 'newMessages', default: 0
    property 'createdAt', Date, default: Date

    # shared credentails for in and out bound
    property 'login'
    property 'account'
    property 'password'

    # data for outbound mails - SMTP
    property 'smtpServer'
    property 'smtpSendAs'
    property 'smtpSsl', Boolean, default: true
    property 'smtpPort', Number, default: 465

    # data for inbound mails - IMAP
    property 'imapServer'
    property 'imapPort'
    property 'imapSecure', Boolean, default: true
    property 'imapLastSync', Date, default: 0
    property 'imapLastFectechDate', Date, default: 0
    # this one is used to build the query to fetch new mails
    property 'imapLastFetchedId', Number, default: 0

    # data regarding the interface
    property 'checked', Boolean, default: true
    property 'color', default: "#0099FF" # color of the mailbox in the list
    property 'statusMsg', default: "Waiting for import" # status visible for user

    # data for import
    # ready to be fetched for new mail
    property 'activated', Boolean, default: false
    property 'status', String, default: "freezed"
    property 'mailsToImport', Number, default: 0

MailFolder = define 'MailFolder', ->
    property 'name'
    property 'path'
    property 'specialType'
    property 'mailbox'
    property 'imapLastFetchedId', Number, default: 0

    property 'mailsToBe', Object
