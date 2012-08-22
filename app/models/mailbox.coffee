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
    port: 465 # port for secure SMTP
    
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
      console.log "Error occured"
      console.log error.message
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
Mailbox.prototype.getAllMail = (callback, job) ->
  
  @updateAttributes {importing: true}, (error) =>
    console.log "# Fetching all mail from " + @
    @getMail "INBOX", ['ALL'], callback, job, "desc"


###
  ## Generic function to downlaod mails from server
  
  # @boxname : name of the inbox, internal to the account on server
  # @constraints : ar array of search critieria
  # @callback : the function on complete or error
  # [@order = "asc"] : the order of getting the messages form server - asc or desc

  # TODO : handle attachements - for now, Cozy doesn't store BLOBs...
###
Mailbox.prototype.getMail = (boxname, constraints, callback, job, order) ->

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
    console.log "[SERVER ERROR]" + error.toString()
    mailbox.updateAttributes {status: error.toString()}, (err) ->
      callback error

  server.on "close", (error) ->
    mailbox.updateAttributes {IMAP_last_sync: new Date().toJSON()}, (err) ->
      if error
        server.emit "error", error
      else
        callback()
  
  # process.on 'uncaughtException', (err) ->
  #   console.error "uncaughtException"
  #   callback err

  emitOnErr = (err) ->
    if err
      server.emit "error", err

  # TODO - socket errors on no-internet kind of situation produces an uncatched error
  # Admittedly, it would be nice to find out why this is not being caught, wouldn't it ?
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
                      # parser = new mailparser.MailParser { streamAttachments: true }
                      parser = new mailparser.MailParser
 
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
                          
                          hasAttachments: mailParsedObject.attachments?
                        
                        mailbox.mails.create mail, (err, mail) ->
            
                          # ERROR
                          emitOnErr err
                          unless err
                          
                            # attachements
                            if mailParsedObject.attachments?
                              for attachment in mailParsedObject.attachments
                                console.log "Attachment: " + attachment.fileName
                                
                                mail.attachments.create {
                                  cid:       attachment.contentId
                                  fileName:  attachment.fileName
                                  contentType: attachment.contentType
                                  length:    attachment.length
                                  checksum:  attachment.checksum
                                  content64: attachment.content.toString()
                                }
                            
            
                            # console.log "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from
                            updates = {
                              activated: true
                              status: totalMailsDone / totalMailsToGo * 100 + "% complete"
                            }
                          
                            # update last fetched element
                            if mail.id_remote_mailbox > mailbox.IMAP_last_fetched_id
                              updates.IMAP_last_fetched_id = mail.id_remote_mailbox
                              updates.IMAP_last_fetched_date = new Date().toJSON()
                        
                            mailbox.updateAttributes updates, (error) ->
                              unless error
                                totalMailsDone++
                                job.progress totalMailsDone, totalMailsToGo
                              else
                                callback error

                      message.on "data", (data) ->
                        parser.write data.toString()

                      message.on "end", ->
                        messageId = message.id
                        messageFlags = message.flags
                        do parser.end

                    fetch.on "end", ->
                      do server.logout