###
  @file: mailbox.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The model used to wrap tasks on other servers:
      * fetching mails with node-imap,
      * parsing mail with nodeparser,
      * saving mail to the database,
      * sending mail with nodemailer,
      * flagging mail on remote servers (not yet implemented)
###


# Just to be able to recognise the mailbox in the console
Mailbox.prototype.toString = () ->
  "[Mailbox " + @name + " #" + @id + "]"

###
  Generic function to send mails, using nodemailer
###
Mailbox.prototype.sendMail = (data, callback) ->
  
  # libraries
  nodemailer = require "nodemailer"

  # lest create the connection - transport object, 
  # and configure it with our mialbox's data
  transport = nodemailer.createTransport("SMTP",
    host: @SMTP_server
    secureConnection: @SMTP_ssl
    port: @SMTP_port
    
    auth:
      user: @login
      pass: @pass
  )

  # let's configure the message object to send
  message =
    from: @SMTP_send_as
    to: data.to
    cc: data.cc if data.cc?
    bcc: data.bcc if data.bcc?
    subject: data.subject
    headers: data.headers if data.headers?
    html: data.html
    generateTextFromHTML: true
    
    # TODO : handle attachements
    
    # attachments: [
    #   # String attachment
    #   fileName: "notes.txt"
    #   contents: "Some notes about this e-mail"
    #   contentType: "text/plain" # optional, would be detected from the filename
    # ,
    #   # Binary Buffer attachment
    #   fileName: "image.png"
    #   contents: new Buffer("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAD/" + "//+l2Z/dAAAAM0lEQVR4nGP4/5/h/1+G/58ZDrAz3D/McH8yw83NDDeNGe4U" + "g9C9zwz3gVLMDA/A6P9/AFGGFyjOXZtQAAAAAElFTkSuQmCC", "base64")
    #   cid: "note@node" # should be as unique as possible
    # ]

  console.log "Sending Mail"
  transport.sendMail message, (error) ->
    if error
      console.error "Error occured"
      console.error error.message
      callback error
    else
      console.log "Message sent successfully!"
      callback()

  transport.close()


###
  # Fetching new mail
###
Mailbox.prototype.getNewMail = (limit=250, callback, job, order)->
  
  order = order or "asc"
  
  id = @IMAP_last_fetched_id + 1
  console.log "# Fetching mail " + @ + " | UID " + id + ':' + (id + limit)
  
  @getMail "INBOX", [['UID', id + ':' + (id + limit)]], callback, job, order

###
  # Fetching all mail, in descending order (the newest ones first).
  # "Flagging the milbox as "activated" when finished"
###
Mailbox.prototype.getAllMail = (job, callback) ->
  
  model = @
  
  @updateAttributes {importing: true}, (error) =>
    console.log "# Fetching all mail from " + @
    
    if model.IMAP_first_fetched_id == -1
      # on new import jobs
      @getMail "INBOX", ['ALL'], callback, job, "desc", "import"
    else
      # retry an interrupted import job
      console.log "1:" + [['UID', "1:" + (model.IMAP_first_fetched_id - 1)]]
      @getMail "INBOX", [['UID', "1:" + (model.IMAP_first_fetched_id - 1)]], callback, job, "desc", "import"


###
  ## Generic function to downlaod mails from server
  
  # @boxname : name of the inbox, internal to the account on server
  # @constraints : ar array of search critieria
  # @callback : the function on complete or error
  # [@order = "asc"] : the order of getting the messages form server - asc or desc

  # TODO : handle attachements - for now, Cozy doesn't store BLOBs...
###
Mailbox.prototype.getMail = (boxname, constraints, callback, job, order, mode="check") ->

  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"

  mailbox = @

  # let's create a connection
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure
  
  
  # set up lsiteners, handle errors and callback
  server.on "alert", (alert) ->
    console.log "[SERVER ALERT]" + alert
      
  server.on "error", (error) ->
    console.error "[SERVER ERROR]: " + error.toString()
    mailbox.updateAttributes {status: error.toString()}, (err) ->
      console.error "Mailbox update with error status"
      callback error
      # some some obscure reason, the following doesn't work
      # if job.data.waitAfterFail?
      #   console.log "Waiting until next try .."
      #   setTimeout () ->
      #     console.log "... next try"
      #     callback error
      #   , job.data.waitAfterFail
      # else
      #   callback error

  server.on "close", (error) ->
    mailbox.updateAttributes {IMAP_last_sync: new Date().toJSON()}, (error) ->
      if error
        server.emit "error", error
      else
        callback()
  
  # process.on 'uncaughtException', (error) ->
  #   console.error "uncaughtException"
  #   server.emit "error", new Error "uncaughtException"

  emitOnErr = (err) ->
    if err
      server.emit "error", err

  # LET THE GAMES BEGIN
  server.connect (err) =>
  
    emitOnErr err 
    unless err
    
      server.openBox boxname, false, (err, box) ->
    
        emitOnErr err
        unless err
        
          # update number of new mails
          mailbox.updateAttributes {new_messages: box.messages.new}, (error) ->
      
            # search mails on server satisfying constraints
            server.search constraints, (err, results) =>
        
              emitOnErr err
              unless err

                # nothing to download
                unless results.length
                  console.log "nothing to download"
                  server.logout()
        
                # mails to fetch
                else
                  console.log "Downloading [" + results.length + "] mails"
                  if order.toUpperCase() == "DESC"
                    results.sort(
                      (a,b) ->
                        b - a
                    )
                  console.log "RESULTS:"
                  console.log results
                                
                  # lets check out how many mails we have to go
                  totalMailsToGo = results.length
                  totalMailsDone = 0
                 
                
                  for id in results
                    
                    messageId = ""
                    messageFlags = []
                
                    fetch = server.fetch id,
                      request:
                        body: "full"
                        headers: false

                    fetch.on "message", (message) ->
                      parser = new mailparser.MailParser { streamAttachments: true }
                      # parser = new mailparser.MailParser
 
                      parser.on "end", (mailParsedObject) ->
                        mail =
                          date:         new Date(mailParsedObject.headers.date).toJSON()
                          dateValueOf:  new Date(mailParsedObject.headers.date).valueOf()
                          createdAt:    new Date().valueOf()
            
                          from:         JSON.stringify mailParsedObject.from
                          to:           JSON.stringify mailParsedObject.to
                          cc:           JSON.stringify mailParsedObject.cc
                          subject:      mailParsedObject.subject
                          priority:     mailParsedObject.priority
            
                          text:         mailParsedObject.text
                          html:         mailParsedObject.html
            
                          id_remote_mailbox: messageId
                          flags:        JSON.stringify messageFlags
            
                          headers_raw:  JSON.stringify mailParsedObject.headers
                          # raw:          JSON.stringify mailParsedObject
              
                          read:         "\\Seen" in messageFlags
                          flagged:      "\\Flagged" in messageFlags
                          
                          hasAttachments: if mailParsedObject.attachments then true else false
                        
                        # let's refresh the object from database, to make sure the attributes are fresh
                        mailbox.reload (error, mailbox) ->
                          
                          # ERROR
                          emitOnErr err
                          unless err
                          
                            # and now we can create a new mail on database, as a child of this mailbox
                            mailbox.mails.create mail, (err, mail) ->
            
                              # ERROR
                              emitOnErr err
                              unless err

                                # just a debug info  on new mail
                                console.log "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from
                            
                                updates = {
                                  activated: true
                                }
                          
                                # update last fetched element
                                if mail.id_remote_mailbox > mailbox.IMAP_last_fetched_id
                                  updates.IMAP_last_fetched_id = mail.id_remote_mailbox
                                  updates.IMAP_last_fetched_date = new Date().toJSON()
                              
                                # update first fetched element
                                if mail.id_remote_mailbox < mailbox.IMAP_first_fetched_id or mailbox.IMAP_first_fetched_id == -1 
                                  updates.IMAP_first_fetched_id = mail.id_remote_mailbox
                        
                                mailbox.updateAttributes updates, (error) ->
                                  unless error
                                    totalMailsDone++
                                    if mode == "import"
                                      job.progress mailbox.IMAP_last_fetched_id - mailbox.IMAP_first_fetched_id, box.messages.total
                                    else
                                      job.progress totalMailsDone, totalMailsToGo
                                  else
                                    callback error

                      message.on "data", (data) ->
                        # on data, we feed the parser
                        parser.write data.toString()

                      message.on "end", ->
                        # additional data to store, which is "forgotten" byt the parser
                        # well, for now, we will store it on the parser itself
                        messageId = message.id
                        messageFlags = message.flags
                        do parser.end
                                      
                    fetch.on "error", (error) ->
                      # undocumented error emitted on fetch() object
                      server.emit "error", error

                    fetch.on "end", ->
                      do server.logout
                      


###
  ## Specialised function to prepare a new mailbox for import and fetching new mail
  
  # TODO : handle attachements - for now, Cozy doesn't store BLOBs...
###

Mailbox.prototype.setupImport = (callback) ->
  
  ## dependences
  imap = require "imap"

  # global vars
  mailbox = @
  debug = true
  
  # let's create a connection
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure

  # set up lsiteners, handle errors and callback
  server.on "alert", (alert) ->
    console.log "[SERVER ALERT]" + alert

  server.on "error", (error) ->
    console.error "[ERROR]: " + error.toString()
    mailbox.updateAttributes {status: error.toString()}, (err) ->
      console.error "Mailbox update with error status"
      callback error

  server.on "close", (error) ->
    console.log "Connection closed: " + error.toString() if debug
        
  emitOnErr = (err) ->
    if err
      server.emit "error", err

  # LET THE GAMES BEGIN
  server.connect (err) =>

    emitOnErr err 
    unless err
    
      console.log "Connection established successfuly" if debug

      server.openBox 'INBOX', false, (err, box) ->

        emitOnErr err
        unless err
        
          console.log "INBOX opened successfuly" if debug
              
          # search mails on server satisfying constraints
          server.search ['ALL'], (err, results) =>

            emitOnErr err
            unless err

              console.log "Search query successful" if debug
              
              # nothing to download
              unless results.length
                console.log "Nothing to download" if debug
                server.logout()
              else
                console.log "[" + results.length + "] mails to download" if debug
                
                mailsToGo = results.length
                mailsDone = 0
                
                maxId = 0
                
                for id in results
                  
                  # find the biggest ID
                  if id > maxId
                    maxId = id
                  
                  mailbox.mailsToBe.create {remoteId: id}, (error, mailToBe) ->
                    
                    # if an error occured, emit it on server
                    if error
                      server.emit "error", error
                    else
                      console.log mailToBe.remoteId + " id saved successfully" if debug
                      mailsDone++
                      # job.progress mailsDone, mailsToGo
                    
                    # synchronise - all ids saved to the db
                    if mailsDone == mailsToGo
                      mailbox.updateAttributes {mailsToImport: results.length, IMAP_last_fetched_id: maxId, activated: true, importing: true}, (err) ->
                        callback err
                      
                    # TODO - timeout for a fail job (blocked or something)



Mailbox.prototype.doImport = (job, callback) ->

  debug = true

  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"
  Step = require "step"

  mailbox = @

  # let's create a connection
  server = new imap.ImapConnection
    username: mailbox.login
    password: mailbox.pass
    host:     mailbox.IMAP_server
    port:     mailbox.IMAP_port
    secure:   mailbox.IMAP_secure

  # set up lsiteners, handle errors and callback
  server.on "alert", (alert) ->
    console.log "[SERVER ALERT]" + alert

  server.on "error", (error) ->
    console.error "[ERROR]: " + error.toString()
    mailbox.updateAttributes {status: error.toString()}, (err) ->
      console.error "Mailbox update with error status" if debug
      callback error

  server.on "close", (error) ->
    console.log "Connection closed: " + error.toString() if debug

  emitOnErr = (error) ->
    if error
      server.logout () ->
        console.log "Error emitted on emitOnErr: " + error.toString() if debug
        server.emit "error", error
  
  # lets get the ids from the database
  mailbox.mailsToBe {order: 'remoteId DESC'}, (err, mailsToBe) ->
    
    emitOnErr err 
    unless err

      if not mailsToBe.length
        console.log "Nothing to download" if debug
        server.logout()
        callback()
      else
      
        # lets connect to the server
        server.connect (err) =>

          emitOnErr err 
          unless err

            console.log "Connection established successfuly" if debug

            server.openBox 'INBOX', false, (err, box) ->

              emitOnErr err
              unless err

                console.log "INBOX opened successfuly" if debug
                
                mailsToGo = mailsToBe.length
                mailsDone = 0
                
                # for every ID which stays in the database
                fetchOne = (i) ->
                  
                  console.log "fetching one: " + i + "/" + mailsToBe.length if debug
                  
                  if i < mailsToBe.length
                    
                    mailToBe = mailsToBe[i]
                  
                    messageId = ""
                    messageFlags = []
            
                    fetch = server.fetch mailToBe.remoteId,
                      request:
                        body: "full"
                        headers: false

                    fetch.on "message", (message) ->
                      parser = new mailparser.MailParser { streamAttachments: true }

                      parser.on "end", (mailParsedObject) ->
                        mail =
                          date:         new Date(mailParsedObject.headers.date).toJSON()
                          dateValueOf:  new Date(mailParsedObject.headers.date).valueOf()
                          createdAt:    new Date().valueOf()
        
                          from:         JSON.stringify mailParsedObject.from
                          to:           JSON.stringify mailParsedObject.to
                          cc:           JSON.stringify mailParsedObject.cc
                          subject:      mailParsedObject.subject
                          priority:     mailParsedObject.priority
        
                          text:         mailParsedObject.text
                          html:         mailParsedObject.html
        
                          id_remote_mailbox: messageId
                          flags:        JSON.stringify messageFlags
        
                          headers_raw:  JSON.stringify mailParsedObject.headers
                          # raw:          JSON.stringify mailParsedObject
          
                          read:         "\\Seen" in messageFlags
                          flagged:      "\\Flagged" in messageFlags
                      
                          hasAttachments: if mailParsedObject.attachments then true else false
                    
                        # and now we can create a new mail on database, as a child of this mailbox
                        mailbox.mails.create mail, (err, mail) ->
    
                          # for now we will just skip messages which are being rejected by parser
                          # emitOnErr err
                          unless err

                            # debug info
                            console.log "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from if debug
                        
                            mailToBe.destroy (error) ->
                              unless error
                              
                                mailsDone++
                                job.progress (mailbox.mailsToImport - (mailsToGo - mailsDone)), mailbox.mailsToImport
                              
                                # next iteration of our asynchronous for loop
                                fetchOne(i + 1)
                                
                                # when finished
                                if mailsToGo == mailsDone
                                  callback()
                              
                                # TODO a timeout
                              else
                                callback error
                          else
                            console.error "Parser error - skipping this message for now"
                            fetchOne(i + 1)

                      message.on "data", (data) ->
                        # on data, we feed the parser
                        parser.write data.toString()

                      message.on "end", ->
                        # additional data to store, which is "forgotten" byt the parser
                        # well, for now, we will store it on the parser itself
                        messageId = message.id
                        messageFlags = message.flags
                        do parser.end
                                  
                    fetch.on "error", (error) ->
                      # undocumented error emitted on fetch() object
                      server.logout () ->
                        console.log "Error emitted on fetch object: " + error.toString() if debug
                        server.emit "error", error

                  else
                    # my job here is done
                    server.logout () ->
                      if mailsToGo != mailsDone
                        callback new Error("Mails to import remain")
                fetchOne(0)