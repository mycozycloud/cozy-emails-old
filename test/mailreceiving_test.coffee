###
  @file: mailreceiving_test.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    The set of test to receive a mail (IMAP).

###
should = require('should')
async = require('async')
Client = require('request-json').JsonClient
app = require('../server')

IMAPFake = require('./IMAP').IMAPFake

client = new Client("http://localhost:8888/")

server = new IMAPFake 8899

describe "Test of mailboxes; ", ->

  before (done) ->
    @app = instantiator()
    @app.compound.on 'models', (models) ->
        {Mailbox} = models
        done()
    @app.listen 8888

  after (done) ->
    @app.compound.server.close()
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
        IMAP_port: 8899
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

  describe "Receive a mail; ", ->

    it "When I schedule a check new mails job; ", (done) ->
      client.get "fetchmailboxandwait/" + @idToRetrieve, (error, response, body) =>
        @response = response
        @body = body
        done()

    it "Then a success is returned", (done) ->
      should.exist @body
      should.exist @body.success
      done()

  describe "Fetch the saved mail from database", ->

    it "When I send the request for a list of mails from this mailbox", (done) ->
      timestamp = new Date().valueOf()
      client.get "mailslist/" + timestamp + ".1", (error, response, body) =>
        @response = response
        @body = body
        done(error)

    it "Then a list is returned", (done) ->
      should.exist @body
      should.exist @body[0]

      mail = @body[0]

      mail.text.should.equal 'html body'
      # mail.cc.should.equal ''
      mail.to.should.equal '[{"address":"support@mycozycloud.com","name":""}]'
      mail.from.should.equal '[{"address":"test@mycozycloud.com","name":""}]'
      mail.priority.should.equal 'normal'
      mail.html.should.equal 'plain text'
      mail.read.should.equal false
      mail.flags.should.equal '[]'
      mail.flagged.should.equal false
      mail.hasAttachments.should.equal false
      mail.subject.should.equal 'Subject'
      # text: 'html body',
      #     cc: null,
      #     to: '[{"address":"support@mycozycloud.com","name":""}]',
      #     from: '[{"address":"test@mycozycloud.com","name":""}]',
      #     subject: 'Subject',
      #     priority: 'normal',
      #     html: 'plain text',
      #     read: false,
      #     flags: '[]',
      #     flagged: false,
      #     hasAttachments: false,

      done()

  describe "Tidy up; ", ->
    it "Now we can delete it", (done) ->
      client.del "mailboxes/" + @idToRetrieve, (error, response, body) =>
        @response = response
        @body = body
        done(error)
