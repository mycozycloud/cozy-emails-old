before ->

  Mail.find req.params.id, (err, box) =>
    if err or !box
      send 403
    else
      @box = box
      next()
, only: ['índex', 'show', 'edit', 'update', 'destroy']

# GET /mailboxes
action 'index', ->
  
  ## dependances
  imap = require "imap"
  mailparser = require "mailparser"
  
  config = {
    "name": "My Name",
    "email": "jaime.la.viande.bovine@gmail.com",
    "username": "jaime.la.viande.bovine@gmail.com",
    "password": "",
    "imap": {
      "host": "imap.gmail.com",
      "port": 993,
      "secure": true
    },
    "smtp": {
      "host": "smtp.gmail.com",
      "ssl": true
    }
  }
  
  #     
  server = new imap.ImapConnection
    username: config.username
    password: config.password
    host: config.imap.host
    port: config.imap.port
    secure: config.imap.secure
    
  mails = []

  exitOnErr = (err) ->
    console.error err
    do process.exit

  server.connect (err) ->
    exitOnErr err if err
    server.openBox "INBOX", false, (err, box) ->
      
      # open or die
      exitOnErr err if err
      
      server.search ["ALL", ['SINCE', 'July 25, 2012']], (err, results) ->
        exitOnErr err if err

        unless results.length
          console.log "No unread messages from #{config.email}"
          do server.logout
          return

        fetch = server.fetch results,
          request:
            body: "full"
            headers: false

        fetch.on "message", (message) ->
          fds = {}
          filenames = {}
          parser = new mailparser.MailParser
          
          parser.on "end", (mail) ->
            mails.push mail

          message.on "data", (data) ->
            parser.write data.toString()

          message.on "end", ->
            do parser.end
            # stock in the database

        fetch.on "end", ->
          send mails
          do server.logout

# POST /mailboxes
action 'create', ->
  Mail.create req.body, (error) =>
    if !error
      send 200
    else
      send 500

# GET /mailboxes/:id
action 'show', ->
  if !@box
    send new Mailbox
  else
    send @box

# PUT /mailboxes/:id
action 'update', ->
  @box.updateAttributes req.body, (error) =>
    if !error
      send 200
    else
      send 500

# DELETE /mailboxes/:id
action 'destroy', ->
  @box.destroy (error) =>
    if !error
      send 200
    else
      send 500