Mailbox.checkAllMailboxes = ->
  Mailbox.all (err, mbs) ->
    for mb in mbs
      Mailbox.getMail(mb)

Mailbox.getMail = (mailbox) ->
  
  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"
  
  
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
      
      server.search ["ALL", ['SINCE', 'July 25, 2012']], (err, results) =>
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
          
          parser.on "end", (mail) =>
            console.log "About to create a new mail: " + JSON.stringify(mail)
            mailbox.mails.create mail, (err, mail) ->
              console.log "New mail created: " + JSON.stringify(mail)

          message.on "data", (data) ->
            parser.write data.toString()

          message.on "end", ->
            do parser.end

        fetch.on "end", ->
          do server.logout