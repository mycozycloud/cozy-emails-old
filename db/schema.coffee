###
  @file: schema.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Objects' descriptions.

###

# User defines user that can interact with the Cozy instance.
User = define 'User', ->
    property 'email', String, index: true
    property 'password', String
    property 'owner', Boolean, default: false
    property 'activated', Boolean, default: false

Mail = define 'Mail', ->
    property 'mailbox', index: true
    property 'id_remote_mailbox',
    property 'createdAt', Number, default: 0, index: true
    property 'dateValueOf', Number, default: 0, index: true
    property 'date', Date, default: 0, index: true
    property 'headers_raw', Text
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
    property 'mail_id', index: true
    property 'cid', Number
    property 'fileName',
    property 'contentType',
    property 'length', Number
    property 'checksum'
    property 'content', Text
    
Mail.hasMany(Attachment, {as: 'attachments',foreignKey: 'mail_id'})

MailSent = define 'MailSent', ->
    property 'mailbox', index: true
    property 'createdAt', Number, default: 0, index: true
    property 'sentAt', Number, default: 0, index: true
    property 'subject',
    property 'from',
    property 'to',
    property 'cc',
    property 'bcc',
    property 'html', Text
    
MailToBe = define 'MailToBe', ->
    property 'remoteId', Number, index: true
    property 'mailbox', index: true
  
# Mailbox object to store the information on connections to remote servers
# and have attached mails
Mailbox = define 'Mailbox', ->
  
    # identification
    property 'name'                             # the name used in the interface, doesn't have to be unique
    property 'config', Number, default: 0       # for predefined configurations
    property 'new_messages', default: 0         # number of new messages for a mailbox
    property 'createdAt', Date, default: Date   # mailbox created at
    
    # shared credentails for in and out bound
    property 'login'
    property 'pass'

    # data for outbound mails - SMTP
    property 'SMTP_server'
    property 'SMTP_send_as'
    property 'SMTP_ssl', Boolean, default: true
    property 'SMTP_port', Number, default: 465

    # data for inbound mails - IMAP
    property 'IMAP_server'
    property 'IMAP_port'
    property 'IMAP_secure', Boolean, default: true
    property 'IMAP_last_sync', Date, default: 0
    property 'IMAP_last_fetched_date', Date, default: 0
    # this one is used to build the query to fetch new mails
    property 'IMAP_last_fetched_id', Number, default: 0

    # data regarding the interface
    property 'checked', Boolean, default: true        # if the mailbox is to be included in the list of mails
    property 'color', default: "#0099FF"              # color of the mailbox in the list
    property 'status', default: "Waiting for import"  # status visible for user
    
    # data for import
    property 'activated', Boolean, default: false # ready to be fetched for new mail
    property 'imported', Boolean, default: false  # if the import was finished
    property 'importing', Boolean, default: false # if the import was started
    property 'mailsToImport', Number, default: 0  # number of mails for the import job
    
Mailbox.hasMany(Mail, {as: 'mails',  foreignKey: 'mailbox'})
Mailbox.hasMany(MailToBe, {as: 'mailsToBe',  foreignKey: 'mailbox'})
Mailbox.hasMany(MailSent, {as: 'mailsSent',  foreignKey: 'mailbox'})


# logs managment
LogMessage = define 'LogMessage', ->
    
    # type:
    #   "info" - standard message
    #   "success" - success message
    #   "warning" - warning message
    #   "error" - error message
    property 'type', String, default: "info"
    
    # timeout:
    #   0 - message will be displayed until user click OK to discard it
    #   > 0 - message will be displayed only once, and will disappear after x seconds
    property 'timeout', Number, default: 5 * 60
    
    property 'text',
    property 'createdAt', Number