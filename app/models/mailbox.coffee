Mailbox.checkAllMailboxes = ->
  Mailbox.all (err, mbs) ->
    for mb in mbs
      mb.getNewMail

Mailbox.prototype.getNewMail = ->
  @getMail ["ALL", ['SINCE', 'July 1, 2012']]


Mailbox.prototype.getMail = (constraints) ->
  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"

  mailbox = this
  
  console.log "getMail of mailbox: " + JSON.stringify(mailbox)
  # 
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure
    
  exitOnErr = (err) ->
    console.error err
    do process.exit

  server.connect (err) =>
    exitOnErr err if err
    
    server.openBox "INBOX", false, (err, box) ->
      
      # open or die
      exitOnErr err if err
      
      server.search constraints, (err, results) =>
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
          parser = new mailparser.MailParser
          
          parser.on "end", (m) =>
            # console.log "About to create a new mail:\n" + JSON.stringify(m)
            mail =
              date:         new Date(m.headers.date).toJSON()
              createdAt:    new Date().toJSON()
              
              from:         JSON.stringify m.from
              to:           JSON.stringify m.to
              subject:      m.subject
              priority:     m.priority
              
              text:         m.text
              html:         m.html
              
              headers_raw:  JSON.stringify m.headers
              raw:          JSON.stringify m
              
              # id_remote_mailbox: m.headers.getAttribute("message-id")
            
            mailbox.mails.create mail, (err, mail) ->
              console.log "New mail created:\n" + JSON.stringify(mail)

          message.on "data", (data) ->
            parser.write data.toString()

          message.on "end", ->
            do parser.end

        fetch.on "end", ->
          do server.logout