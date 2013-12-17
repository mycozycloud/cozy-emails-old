americano = require 'americano-cozy'

module.exports = MailSent = americano.getModel 'MailSent',
    createdAt: {type: Number, default: 0}
    sentAt: {type: Number, default: 0}
    subject: String
    from: String
    to: String
    cc: String
    bcc: String
    html: String

MailSent.date = (params, callback) ->
    MailSent.request "date", params, callback

MailSent.dateId = (params, callback) ->
    MailSent.request "dateId", params, callback
