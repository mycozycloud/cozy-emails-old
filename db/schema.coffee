Note = define 'Template', ->
    property 'title', String, index: true
    property 'content', String
    property 'creationDate', Date, default: Date
    property 'lastModificationDate', Date, default: Date
    property 'content': String
    property 'tags', [String]
    property 'tagParent', String

Tree = define 'Tree', ->
    property 'type', String, default: "Template"
    property 'struct', String

# User defines user that can interact with the Cozy instance.
User = define 'User', ->
    property 'email', String, index: true
    property 'password', String
    property 'owner', Boolean, default: false
    property 'activated', Boolean, default: false
    
    
Mail = define 'Mail', ->
    property 'mailbox', index: true
    property 'id_remote_mailbox', index: true
    property 'createdAt', Number, default: 0, index: true
    property 'date', Date, default: 0, index: true
    property 'headers_raw', Text
    property 'raw', Text
    property 'priority',
    property 'flags',
    property 'subject',
    property 'from',
    property 'to',
    property 'cc',
    property 'text', Text
    property 'html', Text
    #property 'attachements'
    
Attachement = define 'Attachements', ->
    property 'mail_id',
    property 'content_raw'
    
Mail.hasMany(Attachement,   {as: 'attachements',  foreignKey: 'id'});
    
Mailbox = define 'Mailbox', ->
    property 'new_messages', default: 0
    property 'checked', Boolean, default: true
    property 'config', Number, default: 0
    property 'name'
    property 'login'
    property 'pass'
    property 'createdAt', Date, default: Date
    property 'SMTP_server'
    property 'SMTP_send_as'
    property 'SMTP_ssl'
    property 'IMAP_server'
    property 'IMAP_port'
    property 'IMAP_secure', Boolean, default: true
    property 'IMAP_last_sync', Date, default: 0
    property 'IMAP_last_fetched_id', Number, default: 1
    property 'IMAP_last_fetched_date', Date, default: 0
    property 'status'
    property 'color', default: "#0099FF"
    
Mailbox.hasMany(Mail, {as: 'mails',  foreignKey: 'mailbox'});