should = require('should')
async = require('async')
Client = require('request-json').JsonClient
app = require('../server')

client = new Client("http://localhost:8888/")

describe "Test of log messages; ", ->

    before (done) ->
        @mailbox = name: "cozy box"
        LogMessage.destroyAll ->
            done()

    after (done) ->
        done()

    describe "don't create same error twice", ->

        it "Given I created an error and wait for 1s", (done) ->
            LogMessage.createBoxImportError @mailbox, ->
                setTimeout done, 1000

        it "And I created a second error of same type", (done) ->
            LogMessage.createBoxImportError @mailbox, done

        it "And I created a third error of different type", (done) ->
            LogMessage.createImportPreparationError @mailbox, done

        it "When I retrieve log messages", (done) ->
            LogMessage.all (err, logMessages) =>
                should.not.exist err
                @logMessages = logMessages
                done()

        it "I got only two errors", ->
            @logMessages.length.should.equal 2

    describe "don't create same import info twice", ->
        
        it "Given I created an import info and wait for 1s", (done) ->
            results = [ { ok: 1 }, {ok: 2} ]
            LogMessage.createImportInfo results, @mailbox, ->
                setTimeout done, 1000

        it "And I created a second error of same type", (done) ->
            results = [ ok: 3 ]
            LogMessage.createImportInfo results, @mailbox, done

        it "When I retrieve logmessages", (done) ->
            LogMessage.orderedByDate (err, logMessages) =>
                should.not.exist err
                @logMessages = logMessages
                done()

        it "I got only one log message as info", ->
            @logMessages.length.should.equal 3
            @logMessages[0].subtype.should.equal "download"
            @logMessages[0].counter.should.equal 3
