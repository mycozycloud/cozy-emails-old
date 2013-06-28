###
  @file: mailboxes_test.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    Tests set for mailboxes CRUD

###
should = require('should')
async = require('async')
Client = require('request-json').JsonClient
instantiator = require('../server')

client = new Client("http://localhost:8888/")
Mailbox = null

describe "Test of mailboxes", ->

    before (done) ->
        @app = instantiator()
        @app.compound.on 'models', (models) ->
            {Mailbox} = models
            done()
        @app.listen 8888

    before (done) ->
        Mailbox.destroyAll done

    after (done) ->
        @app.compound.server.close()
        done()

    describe "Creation and update of a mailbox", ->

        it "When I send data for a mailbox creation", (done) ->
            mailbox =
                name: "test.smpt.fr"
                login: "logintest"
                password: "password"
                smtpServer: "test.smpt.fr"
                smtpSendAs: "mailman"
                smtpSsl: "true"
                imapServer: "localhost"
                imapPort: 993
                imapSecure: "true"


            client.post "mailboxes/", mailbox, (error, response, body) =>
                @response = response
                @body = body
                done(error)

        it "Then a success is returned that contains a mailbox with an id", (done) ->
            console.log @body
            should.exist @body
            should.exist @body.id
            @response.statusCode.should.equal 200

            @body.login.should.equal "logintest"

            @idToRetrieve = @body.id

            done()

    describe "Now let's check the update", ->

        it "Once it's stored, we can retrieve it by its id (show)", (done) ->
                client.get "mailboxes/" + @idToRetrieve, (error, response, body) =>
                    @body = body
                    done()

        it "And the data should be the same, as stored in the beginning", (done) ->
            should.exist @body

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
            client.del "mailboxes/" + @idToRetrieve, (error, response, body) =>
                @response = response
                @body = body
                done(error)


    describe "Deletion of a mailbox and related ", ->

        before (done) ->
            Mailbox.destroyAll ->
                Mail.destroyAll ->
                    MailToBe.destroyAll ->
                        Attachment.destroyAll ->
                            done()

        it "Given there is a mailbox", (done) ->
            Mailbox.create name: "test mailbox", (err, mailbox) =>
                should.not.exist err
                @mailbox = mailbox
                done()

        it "And 40 mails linked to this mailbox", (done) ->
            mails = []
            data = (i) =>
                text: "test mail #{i}"
                mailbox: @mailbox.id
            mails.push data(i) for i in [1..40]
            createFunc = (mail, callback) -> Mail.create mail, callback
            async.forEachSeries mails, createFunc, (err) ->
                should.not.exist err
                done()

        it "And 40 mailtobe linked to this mailbox", (done) ->
            mailtobes = []
            data = (i) =>
                remoteId: "#{i}"
                mailbox: @mailbox.id
            mailtobes.push data(i) for i in [1..40]
            createFunc = (mailToBe, callback) ->
                MailToBe.create mailToBe, callback
            async.forEachSeries mailtobes, createFunc, (err) ->
                should.not.exist err
                done()

        it "And 40 attachments linked to this mailbox", (done) ->
            attachments = []
            data = (i) =>
                fileName: "fileName #{i}"
                mailbox: @mailbox.id
            attachments.push data(i) for i in [1..40]
            createFunc = (attachment, callback) ->
                Attachment.create attachment, callback
            async.forEachSeries attachments, createFunc, (err) ->
                should.not.exist err
                done()

        it "When I delete the mailbox", (done) ->
            client.del "mailboxes/#{@mailbox.id}", (err, res, body) ->
                should.not.exist err
                res.statusCode.should.equal 204
                done()

        it "Then there is no mailbox anymore", (done) ->
            Mailbox.all (err, mailboxes) ->
                mailboxes.length.should.equal 0
                done()

        it "And no mails related to this box", (done) ->
            Mail.fromMailbox key: @mailbox.id, (err, mails) ->
                mails.length.should.equal 0
                done()

        it "And no mailToBes related to this box", (done) ->
            params =
                startKey: @mailbox.id
                endKey: @mailbox.id + "0"
            MailToBe.fromMailbox params, (err, mailtobes) ->
                mailtobes.length.should.equal 0
                done()

        it "And no attachements related to this box", (done) ->
            Attachment.fromMailbox key: @mailbox.id, (err, attachments) ->
                attachments.length.should.equal 0
                done()
