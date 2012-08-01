{Mail} = require "../models/mail"

class exports.MailsCollection extends Backbone.Collection
    
  model: Mail
  url: 'mails/'

  comparator: (Mail) ->
    Mail.get("date")