BaseModel = require("./models").BaseModel

###
    @file: mailbox.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        A model which defines the MAILBOX object.
        MAILBOX stocks all the data necessary for a successful connection to
        IMAP and SMTP servers, and all the data relative to this mailbox,
        internal to the application.
###
class exports.Mailbox extends BaseModel

    urlRoot: 'mailboxes/'

    defaults:
        checked: true
        config: 0
        name: "box"
        login: "login"
        password: "pass"
        smtpServer: "smtp.gmail.com"
        smtpSsl: true
        smtpSendAs: "support@mycozycloud.com"
        imapServer: "imap.gmail.com"
        imapPort: 993
        imapSecure: true
        color: "orange"

    imapLastFetchedDate: ->
        parsed = new Date @get("IMapLastFetchedDate")
        parsed.toUTCString()

    deltaNewMessages: (delta) ->
        current = parseInt @get("newMessages")
        @set "newMessages", current + delta

    destroy: (options) ->
        success = options.success
        id = @id
        options.success = ->
            app.folders.forEach (folder) ->
                console.log folder, id
                app.folders.remove folder if folder.get('mailbox') is id
            app.mails.forEach (mail) ->
                console.log mail, id
                app.mails.remove mail if mail.mailbox is id

            success.apply(this, arguments) if success

        super options

