nodemailer = require "nodemailer"

class MailSender

    constructor: (@mailbox) ->

    sendMail: (data, callback) ->
        # create the connection - transport object, 
        # and configure it with our mailbox's data
        transport = nodemailer.createTransport "SMTP",
            host: @mailbox.smtpServer
            secureConnection: @mailbox.smtpSsl
            port: @mailbox.smtpPort
            auth:
                user: @mailbox.login
                pass: @mailbox.password

        # configure the message object to send
        message =
            from: @mailbox.smtpSendAs
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
