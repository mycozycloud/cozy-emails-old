should = require('should')
async = require('async')
Client = require('../common/test/client').Client
app = require('../server')


client = new Client("http://localhost:8888/")


describe "Test section", ->

    before (done) ->
        app.listen(8888)
        done()

    after (done) ->
        app.close()
        done()

    describe "POST /mailboxes/ Create a mailbox", ->
        it "When I send data for a mailbox creation", (done) ->
            mailbox =
                name: "mailbox test"
                login: "logintest"
                pass: "password"
                SMTP_server: "test.smpt.fr"
                SMTP_send_as: "mailman"
                SMTP_ssl: "true"
                IMAP_host: "localhost"
                IMAP_port: 993
                IMAP_secure: "true"


            client.post "mailboxes/", mailbox, (error, response, body) =>
                @response = response
                @body = body
                done()

        it "Then a success is returned that contains a mailbox with an id", ->
            should.exist @body
            should.exist @body.id
            @response.statusCode.should.equal 201

            @body.login.should.equal "logintest"
