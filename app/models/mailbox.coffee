Mailbox.checkAllMailboxes = (callback) ->
  Mailbox.all (err, mbs) ->
    return callback err if err
    for mb in mbs
      mb.getNewMail 250, callback
      
Mailbox.prototype.toString = () ->
  "[Mailbox " + @name + " #" + @id + "]"

Mailbox.prototype.getNewMail = (limit=250, callback)->
  id = @IMAP_last_fetched_id + 1
  console.log "# Fetching mail " + @ + " | UID " + id + ':' + (id + limit)
  
  @getMail "INBOX", [['UID', id + ':' + (id + limit)]], callback

Mailbox.prototype.getAllMail = (callback) ->
  console.log "# Fetching all mail"
  @getMail "INBOX", ['ALL'], callback

Mailbox.prototype.getMail = (boxname, constraints, callback) ->
  
  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"

  mailbox = @

  # so  let's create 
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure
  
  exitOnErr = (err) =>
    @status = err.toString()
    @save()
    callback err

  server.connect (err) =>
  
    # ERROR
    if err
      exitOnErr err 
      return
  
    server.openBox boxname, false, (err, box) ->
    
      # ERROR
      if err
        exitOnErr err 
        return
    
      server.search constraints, (err, results) =>
        
        # ERROR
        if err
          exitOnErr err 
          return

        unless results.length
          # console.log "nothing to download"
          callback()
          mailbox.status = ""
          mailbox.save()
          do server.logout
          return

        fetch = server.fetch results,
          request:
            body: "full"
            headers: false

        fetch.on "message", (message) ->
          parser = new mailparser.MailParser { streamAttachments: true }
        
          parser.on "end", (m) =>
            mail =
              date:         new Date(m.headers.date).toJSON()
              createdAt:    new Date().valueOf()
            
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
              if err
                exitOnErr err 
                return
            
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

          message.on "data", (data) ->
            parser.write data.toString()

          message.on "end", ->
            parser.message_id = message.id
            parser.message_flags = message.flags
            do parser.end

        fetch.on "end", ->
          mailbox.status = ""
          mailbox.save()
          callback()
          do server.logout