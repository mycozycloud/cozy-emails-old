nodemailer = require "nodemailer"

# Utiliy class to send mail from a given inbox.
class MailSender

    constructor: (@mailbox) ->

    # Send a mail via the smtp server configured in the given mailbox.
    # Mail data (target address, content, subject...) are given in parameters.
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
