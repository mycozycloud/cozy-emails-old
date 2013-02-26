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

    @urlRoot: 'mailboxes/'
    
    @url: 'mailboxes/'

    defaults:
        checked: true
        config: 0
        name: "box"
        login: "login"
        password: "pass"
        SmtpServer: "smtp.gmail.com"
        SmtpSsl: true
        SmtpSendAs: "support@mycozycloud.com"
        ImapServer: "imap.gmail.com"
        ImapPort: 993
        ImapSecure: true
        color: "orange"

    initialize: ->
        @on "destroy", @removeView, @

    redrawView: ->
        @view.render() if @view?

    removeView: ->
        @view.remove() if @view?
        
    IMAPLastFetchedDate: ->
        parsed = new Date @get("IMapLastFetchedDate")
        parsed.toUTCString()
