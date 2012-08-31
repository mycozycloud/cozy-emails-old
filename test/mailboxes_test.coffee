###
  @file: mailboxes_test.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Tests set for mailboxes CRUD

###
should = require('should')
async = require('async')
Client = require('../common/test/client').Client
app = require('../server')

client = new Client("http://localhost:8888/")

describe "Test of mailboxes; ", ->

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
                done(error)

        it "Then a success is returned that contains a mailbox with an id", (done) ->
            
            # @body = JSON.parse @body
            should.exist @body
            should.exist @body.id
            @response.statusCode.should.equal 200

            @body.login.should.equal "logintest"
            
            @idToRetrieve = @body.id
            
            done()
            
    describe "Nom let's check the update; ", ->
            
        it "Once it's stored, we can retrieve it by its id (show)", (done) ->
            client.get "mailboxes/" + @idToRetrieve, (error, response, body) =>
                @response = response
                @body = body
                done(error)
        
        it "And the data should be the same, as stored in the beginning", (done) ->
            
            @body = JSON.parse @body
            should.exist @body
            # should.exist @body.id

            @body.login.should.equal "logintest"
            @body.SMTP_server.should.equal "test.smpt.fr"
            @body.name.should.equal "test.smpt.fr"

            done()
            
        it "Also, it's nice to be able to update the object, via its id", (done) ->
            attrs = {
              checked: false
              config: 128
              name: "name_updated"
              login: "login_updated"
              pass: "pass_updated"
              SMTP_server: "test.smtp.server.domain"
              SMTP_ssl: false
              SMTP_send_as: "test_send_as"
              IMAP_server: "test.server.domain"
              IMAP_port: "123"
              IMAP_secure: false
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
          
            @body = JSON.parse @body
          
            should.exist @body
            should.exist @body.id

            @body.checked.should.equal false
            @body.config.should.equal 128
            @body.name.should.equal "name_updated"
            @body.login.should.equal "login_updated"
            @body.pass.should.equal "pass_updated"
            @body.SMTP_server.should.equal "test.smtp.server.domain"
            @body.SMTP_ssl.should.equal false
            @body.SMTP_send_as.should.equal "test_send_as"
            @body.IMAP_server.should.equal "test.server.domain"
            @body.IMAP_port.should.equal "123"
            @body.IMAP_secure.should.equal false
            @body.color.should.equal "red hot chilli"

            done()

        it "Now we can delete it", (done) ->
            client.delete "mailboxes/" + @idToRetrieve, (error, response, body) =>
                @response = response
                @body = body
                done(error)
