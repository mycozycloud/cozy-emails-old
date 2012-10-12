###
  @file: mailsending_test.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Tests set to verify CozyMail send well the messages.

###
should = require('should')
async = require('async')
Client = require('request-json').JsonClient
app = require('../server')

SMTPFake = require('./SMTP').SMTPFake

client = new Client("http://localhost:8888/")

server = new SMTPFake 8889

describe "Test of mailboxes; ", ->

    before (done) ->
        app.listen(8888)
        done()

    after (done) ->
        app.close()
        done()

    describe "Create a mailbox; ", ->
        it "When I send data for a mailbox creation", (done) ->
            mailbox =
                name: "test"
                login: "logintest"
                pass: "passwordtest"
                SMTP_server: "localhost"
                SMTP_send_as: "test@localhost"
                SMTP_port: 8889
                SMTP_ssl: false
                IMAP_host: "localhost"
                IMAP_port: 993
                IMAP_secure: false

            client.post "mailboxes/", mailbox, (error, response, body) =>
                @response = response
                @body = body
                done(error)

        it "Then a success is returned that contains a mailbox with an id", (done) ->
            should.exist @body
            should.exist @body.id
            @response.statusCode.should.equal 200

            @body.login.should.equal "logintest"
            
            @idToRetrieve = @body.id
            
            done()

    describe "Send a mail; ", ->
        it "When I send data for a mail to send", (done) ->
            mail =
              to: "support@mycozycloud.com"
              subject: "Test"
              html: "<br>This is html message</b>"
              cc: ""
              bcc: ""

            client.post "sendmail/" + @idToRetrieve, mail, (error, response, body) =>
                @response = response
                @body = body
                done(error)

        it "Then a success is returned", (done) ->
            should.exist @body
            should.exist @body.success

            done()
    describe "Tidy up; ", ->
      it "Now we can delete it", (done) ->
          client.del "mailboxes/" + @idToRetrieve, (error, response, body) =>
              @response = response
              @body = body
              done(error)
