BaseModel = require("./models").BaseModel
# {AttachmentsCollection} = require 'collections/attachments'

###
    @file: mail.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Model which defines the MAIL object.
###
class exports.Email extends BaseModel

    urlRoot: "emails/"

    initialize: ->
        super
        @url = BaseModel::url
        # @attachments = new AttachmentsCollection [],
        #     comparator: 'filename'
        #     model: require('models/attachment').Attachment
        #     url: @url() + '/attachments'

    getMailbox: ->
        @mailbox ?= window.app.mailboxes.get @get "mailbox"
        @mailbox

    getColor: ->
        @getMailbox()?.get("color") or "white"

    parse: (attributes) ->
        if 'string' is typeof attributes.flags
            attributes.flags = JSON.parse(attributes.flags)

        attributes


    ###
        Changing mail properties - read and flagged
    ###

    isRead: ->    -1 isnt _.indexOf @get('flags'), "\\Seen"
    isFlagged: -> -1 isnt _.indexOf @get('flags'), "\\Flagged"

    markRead: (read = true) ->
        if read then @set 'flags', _.union @get('flags'), ["\\Seen"]
        else @set 'flags', _.without @get('flags'), "\\Seen"

    markFlagged: (flagged=true) ->
        if flagged then @set 'flags', _.union @get('flags'), ["\\Flagged"]
        else @set 'flags', _.without @get('flags'), "\\Flagged"


    ###
        RENDERING - these functions attr() replace @get "attr", and add
        some parsing logic.  To be used in views, to keep the maximum of
        logic related to mails in one place.
    ###

    asEmailList: (field, out) ->
        parsed = JSON.parse @get field
        for obj in parsed
            out += "#{obj.name} <#{obj.address}>, "
        out.substring(0, out.length - 2)

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
        out = @asEmailList "cc", out if @get "cc"
        console.log out
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
        parsed = moment @get("date")
        parsed.calendar()

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
        if @hasHtml() then @html() else @text()

    textOrHtml: ->
        if @hasText() then @text() else @html()
