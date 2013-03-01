nodemailer = require "nodemailer"

class MailSender

    constructor: (@mailbox) ->

    sendMail: (data, callback) ->
        # create the connection - transport object, 
        # and configure it with our mailbox's data
        transport = nodemailer.createTransport "SMTP",
            host: @mailbox.SmtpServer
            secureConnection: @mailbox.SmtpSsl
            port: @mailbox.SmtpPort
            auth:
                user: @mailbox.login
                pass: @mailbox.password

        # configure the message object to send
        message =
            from: @mailbox.SmtpSendAs
            to: data.to
            cc: data.cc if data.cc?
            bcc: data.bcc if data.bcc?
            subject: data.subject
            headers: data.headers if data.headers?
            html: data.html
            generateTextFromHTML: true
     
        transport.sendMail message, callback
        transport.close()

module.exports = MailSender
