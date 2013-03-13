###
  @file: schema.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    Objects' descriptions.

###

# User defines user that can interact with the Cozy instance.
User = define 'User', ->
    property 'email', String
    property 'password', String
    property 'owner', Boolean, default: false
    property 'activated', Boolean, default: false

Mail = define 'Mail', ->
    property 'mailbox'
    property 'idRemoteMailbox',
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
    property 'flags',
    property 'read', Boolean, default: false
    property 'flagged', Boolean, default: false
    property 'hasAttachments', Boolean, default: false
    property 'inReplyTo'
    property 'references'

Attachment = define 'Attachment', ->
    property 'mailId'
    property 'cid', Number
    property 'fileName',
    property 'contentType',
    property 'length', Number
    property 'checksum'
    property 'content', Text
    property 'mailbox',

Mail.hasMany Attachment, {as: 'attachments', foreignKey: 'mail_id'}

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

MailToBe = define 'MailToBe', ->
    property 'remoteId', Number
    property 'mailbox'

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
    property 'smtpSserver'
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
    property 'status', default: "Waiting for import" # status visible for user

    # data for import
    # ready to be fetched for new mail
    property 'activated', Boolean, default: false
    property 'imported', Boolean, default: false
    property 'importing', Boolean, default: false
    property 'mailsToImport', Number, default: 0

Mailbox.hasMany Mail, {as: 'mails',  foreignKey: 'mailbox'}
Mailbox.hasMany MailToBe, {as: 'mailsToBe', foreignKey: 'mailbox'}
Mailbox.hasMany MailSent, {as: 'mailsSent', foreignKey: 'mailbox'}


# logs managment
LogMessage = define 'LogMessage', ->

    # type:
    #   "info" - standard message
    #   "success" - success message
    #   "warning" - warning message
    #   "error" - error message
    property 'type', String, default: "info"
    property 'subtype', String, default: "info"

    # timeout:
    #   0 - message will be displayed until user click OK to discard it
    #   > 0 - message will be displayed only once, and will disappear after x seconds
    property 'timeout', Number, default: 5 * 60
    property 'text',
    property 'createdAt', Number
    property 'mailbox', String
    property 'counter', Number
