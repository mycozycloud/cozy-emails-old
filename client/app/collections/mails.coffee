{Mail} = require "models/mail"

###
    @file: mails.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The collection to store emails - gets populated with the content of
        the database.
###
class exports.MailsCollection extends Backbone.Collection

    model: Mail
    url: 'mails/'

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

    fetchOlder: (options) ->
        success = options.success or ->
        options ?= {}
        options.url = "folders/#{@timestampOld}/#{@mailsAtOnce}/#{@lastIdOld}"
        options.remove = false
        options.success = (collection) =>
            @timestampNew = @at(0).get("dateValueOf") if @length > 0
            success.call @, arguments

        @fetch options

    fetchFolder: (folderid, limit) ->
        @fetch
            url: "folders/#{folderid}/#{limit}/undefined"
            # remove: false
            success: (collection) =>
                @folderId = folderid
                @timestampNew = @at(0).get("dateValueOf") if @length > 0
                @timestampOld = @last().get("dateValueOf") if @length > 0