Mailbox.checkAllMailboxes = (callback) ->
  Mailbox.all (err, mbs) ->
    return callback err if err
    for mb in mbs
      mb.getNewMail 50, callback

Mailbox.prototype.getNewMail = (limit=100, callback)->
  id = @IMAP_last_fetched_id + 1
  console.log "# Fetching mail | UID " + id + ':' + (id + limit)
  
  @getMail "INBOX", [['UID', id + ':' + (id + limit)]], callback

Mailbox.prototype.getAllMail = (callback) ->
  console.log "# Fetching all mail"
  @getMail "INBOX", ['ALL'], callback

Mailbox.prototype.getMail = (boxname, constraints, callback) ->
  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"

  mailbox = @
  # 
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure
    
  exitOnErr = (err) ->
    console.error err
    callback err
    return

  server.connect (err) =>
    
    # ERROR
    exitOnErr err if err
    
    server.openBox boxname, false, (err, box) ->
      
      # ERROR
      exitOnErr err if err
      
      server.search constraints, (err, results) =>
        exitOnErr err if err

        unless results.length
          # console.log "nothing to download"
          callback()
          do server.logout
          return
        
        # console.log "Fetching #{results.length} mails"

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
              cc:           JSON.stringify m.cc
              subject:      m.subject
              priority:     m.priority
              
              text:         m.text
              html:         m.html
              
              id_remote_mailbox: parser.message_id
              flags:        JSON.stringify parser.message_flags
              
              headers_raw:  JSON.stringify m.headers
              raw:          JSON.stringify m
            
            mailbox.mails.create mail, (err, mail) ->
              
              # ERROR
              exitOnErr err if err
              
              console.log "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from
              
              # update last fetched element
              if mail.id_remote_mailbox > mailbox.IMAP_last_fetched_id
                mailbox.IMAP_last_fetched_id = mail.id_remote_mailbox
                mailbox.IMAP_last_fetched_date = new Date().toJSON()
                mailbox.save()
              
              # update new mail counter
              unless "\\Seen" in JSON.parse mail.flags
                mailbox.new_messages++ 
                mailbox.save()
              
              # callback "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from

          message.on "data", (data) ->
            parser.write data.toString()

          message.on "end", ->
            parser.message_id = message.id
            parser.message_flags = message.flags
            do parser.end

        fetch.on "end", ->
          # console.log "appel callback done"
          callback()
          do server.logout