{Email} = require "models/email"

###
    @file: mails.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The collection to store emails - gets populated with the content of
        the database.
###
class exports.MailsCollection extends Backbone.Collection

    model: Email
    url: 'emails/'

    # timestamps:
    #     * timestampMiddle doesn't change - shows which mails are "new"
    #       (fetched after rendering of the interface), and the "old" ones
    #     * timestampNew - the newest mail (sort, and next queries of fetchNew
    #       ask for newer)
    #     * timestampOld - the oldest mail (sort and next quesries ask fof
    #       olders ("load more" button))
    timestampNew:    new Date().valueOf()
    timestampOld:    new Date().valueOf()
    timestampMiddle: new Date().valueOf()

    # number of mails to fetch at one click on "more mail" button
    mailsAtOnce: 100

    fetchOlder: () =>
        if @folderId is 'rainbow'
            @fetchRainbow @mailsAtOnce, @last().get "dateValueOf"
        else
            @fetchFolder @folderId, @mailsAtOnce, @last().get "dateValueOf"

    fetchFolder: (folderid, limit, from) =>
        @reset [] unless from
        @folderId = folderid
        @fetch
            url: "folders/#{folderid}/#{limit}/#{from}"
            remove: false
            success: (collection) =>
                @timestampNew = @at(0).get("dateValueOf") if @length > 0
                @timestampOld = @last().get("dateValueOf") if @length > 0

    fetchRainbow: (limit, from) =>
        @reset [] unless from
        @folderId = 'rainbow'
        @fetch
            url: "emails/rainbow/#{limit}/#{from}"
            remove: false
            success: (collection) =>
                @timestampNew = @at(0).get("dateValueOf") if @length > 0
                @timestampOld = @last().get("dateValueOf") if @length > 0
