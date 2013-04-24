BaseModel = require("./models").BaseModel

###
    @file: mail.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Model which defines the MAIL object.
###
class exports.Mail extends BaseModel

    initialize: ->
        @on "destroy", @removeView, @
        @on "change", @redrawView, @

    mailbox: ->
        if not @mailbox
            @mailbox = window.app.appView.mailboxes.get @get "mailbox"
        @mailbox

    getColor: ->
        box = window.app.appView.mailboxes.get @get "mailbox"
        if box
            box.get "color"
        else
            "white"

    redrawView: ->
        @view.render() if @view?

    removeView: ->
        @view.remove() if @view?

    ###
        RENDERING - these functions attr() replace @get "attr", and add
        some parsing logic.  To be used in views, to keep the maximum of
        logic related to mails in one place.
    ###

    asEmailList: (field, out) ->
        parsed = JSON.parse @get field
        for obj in parsed
            out += "#{obj.name} <#{obj.address}>, "

    from: ->
        out = ""
        @asEmailList "from", out if @get "from"
        out

    fromShort: ->
        out = ""
        if @get "from"
            parsed = JSON.parse @get "from"
            for obj in parsed
                if obj.name
                    out += obj.name + " "
                else
                    out += obj.address + " "
        out

    cc: ->
        out = ""
        @asEmailList "cc", out if @get "cc"
        out

    ccShort: ->
        out = ""
        if @get "cc"
            parsed = JSON.parse @get "cc"
            for obj in parsed
                out += obj.name + " "
        out

    fromAndCc: ->
        out = ""
        @asEmailList "from", out if @get "from"
        @asEmailList "cc", out if @get "cc"
        out

    date: ->
        parsed = new Date @get("date")
        parsed.toUTCString()

    respondingToText: ->
        "#{@fromShort()} on #{@date()} wrote:"

    subjectResponse: (mode="answer") ->
        subject = @get "subject"
        switch mode
            when "answer" then "RE: " + subject.replace(/RE:?/, "")
            when "answer_all" then "RE: " + subject.replace(/RE:?/, "")
            when "forward" then "FWD: " + subject.replace(/FWD:?/, "")
            else subject

    ccResponse: (mode="answer") ->
        switch mode
            when "answer_all" then @cc()
            else ""

    toResponse: (mode="answer") ->
        switch mode
            when "answer" then @from()
            when "answer_all" then @from()
            else ""

    text: ->
        @get("text").replace(/\r\n|\r|\n/g, "<br />")

    html: ->
        expression = new RegExp("(<style>(.|\s)*?</style>)", "gi")
        exp = ///
            /(<style>(.|\s)*?</style>)/ig
            ///
        string = new String @get("html")
        string.replace expression, ""

    hasHtml: ->
        html = @get "html"
        html? and html != ""

    hasText: ->
        text = @get "text"
        text? and text != ""

    hasAttachments: ->
        @get "hasAttachments"

    htmlOrText: ->
        if @hasHtml()
            @html()
        else
            @text()

    textOrHtml: ->
        if @hasText()
            @text()
        else
            @html()

    ###
        Changing mail properties - read and flagged
    ###

    isUnread: ->
        not @get("read")

    setRead: (read=true) ->
        stringFlags = @get "flags"
        flags = "[]" if  typeof(stringFlags) is "object"
        flags = JSON.parse stringFlags if typeof(stringFlags) is "string"
        if read
            unless "\\Seen" in flags
                console.log flags
                console.log typeof(flags)

                flags.push("\\Seen")
                box = window.app.appView.mailboxes.get @get("mailbox")
                box?.set "newMessages", (parseInt(box.get("newMessages")) - 1)
            @set read: true
        else
            flagsPrev = flags.length
            flags = $.grep flags, (val) ->
                val isnt "\\Seen"
            unless flagsPrev is flags.length
                box = window.app.appView.mailboxes.get @get("mailbox")
                box?.set "newMessages", ((parseInt box?.get "newMessages") + 1)
            @set read: false
        @set flags: JSON.stringify(flags)

    isFlagged: ->
        @get "flagged"

    setFlagged: (flagged=true) ->
        flags = JSON.parse @get("flags")

        if flagged
            unless "\\Flagged" in flags
                flags.push("\\Flagged")
        else
            flags = $.grep flags, (val) ->
                val isnt "\\Flagged"

        @set flagged: flagged
        @set flags: JSON.stringify(flags)
