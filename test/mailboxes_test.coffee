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

    describe "Creation and update of a mailbox; ", ->
        it "When I send data for a mailbox creation", (done) ->
            mailbox =
                name: "test.smpt.fr"
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

        it "Then a success is returned that contains a mailbox with an id", (done) ->
            should.exist @body
            should.exist @body.mailbox.id
            @response.statusCode.should.equal 200

            @body.mailbox.login.should.equal "logintest"
            
            @idToRetrieve = @body.mailbox.id
            
            done()
            
        it "Once it's stored, we can retrieve it by its id (show)", (done) ->
            client.get "mailboxes/" + @idToRetrieve, (error, response, body) =>
                @response = response
                @body = body
                done(error)
        
        it "And the data should be the same, as stored in the beginning", (done) ->
            console.log "BOOOODY: " + @body + " END BODY"
            should.exist @body
            # should.exist @body.id

            @body.login.should.equal "logintest"
            @body.SMTP_server.should.equal "test.smpt.fr"
            @body.name.should.equal "test.smpt.fr"

            done()
            
        it "Also, it's nice to be able to update the object, via its id", (done) ->
            attrs = {
              checked: "yes"
              config: "128"
              name: "name_updated"
              login: "login_updated"
              pass: "pass_updated"
              SMTP_server: "test.smtp.server.domain"
              SMTP_ssl: "yeah"
              SMTP_send_as: "test_send_as"
              IMAP_server: "test.server.domain"
              IMAP_port: "123"
              IMAP_secure: "yeah"
              color: "red hot chilli"
            }
            client.put "mailboxes/" + @idToRetrieve, attrs, (error, response, body) =>
                @response = response
                @body = body
                done()
                
        it "And make sure it was updated", (done) ->
            client.get "mailboxes/" + @idToRetrieve, (error, response, body) =>
                @response = response
                @body = body
                done()
                
        it "And all of the values are changed", (done) ->
            should.exist @body
            should.exist @body.id

            @body.checked.should.equal "yes"
            @body.config.should.equal "128"
            @body.name.should.equal "name_updated"
            @body.login.should.equal "login_updated"
            @body.pass.should.equal "pass_updated"
            @body.SMTP_server.should.equal "test.smtp.server.domain"
            @body.SMTP_ssl.should.equal "yeah"
            @body.SMTP_send_as.should.equal "test_send_as"
            @body.IMAP_server.should.equal "test.server.domain"
            @body.IMAP_port.should.equal "123"
            @body.IMAP_secure.should.equal "yeah"
            @body.color.should.equal "red hot chilli"

            done()