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
        smtpServer: "smtp.gmail.com"
        smtpSsl: true
        smtpSendAs: "support@mycozycloud.com"
        imapServer: "imap.gmail.com"
        imapPort: 993
        imapSecure: true
        color: "orange"

    initialize: ->
        @on "destroy", @removeView, @

    redrawView: ->
        @view.render() if @view?

    removeView: ->
        @view.remove() if @view?
        
    imapLastFetchedDate: ->
        parsed = new Date @get("IMapLastFetchedDate")
        parsed.toUTCString()
