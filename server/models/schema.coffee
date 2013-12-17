###
  @file: schema.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    Objects' descriptions.

###

# User defines user that can interact with the Cozy instance.
Mail = define 'Mail', ->
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
