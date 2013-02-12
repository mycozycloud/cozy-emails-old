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

fs = require 'fs'
async = require 'async'

saveAttachments = (mail, attachments, callback) ->
    if attachments?
        attachFuncs = []
        for attachment in attachments
            console.log "Attachment: " + attachment.fileName + "/" + mail.id
            console.log mail
            
                            
            params =
                cid: attachment.contentId
                fileName: attachment.fileName
                contentType: attachment.contentType
                length: attachment.length
                mail_id: mail.id
                checksum: attachment.checksum

            attachFunc = (callback) ->
                Attachment.create params, (error, attach) ->
                    fs.writeFile "/tmp/#{attachment.fileName}", attachment.content, ->
                        attach.attachFile "/tmp/#{attachment.fileName}", callback
            attachFuncs.push attachFunc
        async.series attachFuncs, callback
            
    else
        callback()



# Just to be able to recognise the mailbox in the console
Mailbox::toString = () ->
  "[Mailbox " + @name + " #" + @id + "]"

###
  Generic function to send mails, using nodemailer
###
Mailbox::sendMail = (data, callback) ->
  
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
  ## Fetching new mail from server
  
  # @job - kue job
  # @callback - success callback
  # @limit - how many new messages we want to download at max

  # TODO : handle attachments - for now Cozy doesn't store BLOBs...
###
Mailbox::getNewMail = (job, callback, limit=250)->
  
  ## dependences
  imap = require "imap"
  mailparser = require "mailparser"

  # global vars
  debug = true
  
  # reload
  @reload (error, mailbox) ->
    
    if error
      callback error
    else
      id = Number(mailbox.IMAP_last_fetched_id) + 1
      console.log "Fetching mail " + mailbox + " | UID " + id + ':' + (id + limit) if debug
  
      # let's create a connection
      server = new imap.ImapConnection
        username: mailbox.login
        password: mailbox.pass
        host:     mailbox.IMAP_server
        port:     mailbox.IMAP_port
        secure:   mailbox.IMAP_secure

      # set up listeners, handle errors and callback
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
              server.search [['UID', id + ':' + (id + limit)]], (err, results) =>

                emitOnErr err
                unless err

                  console.log "Search query successful" if debug
              
                  # nothing to download
                  unless results.length
                    console.log "Nothing to download" if debug
                    server.logout () ->
                      callback()
                  else
                    console.log "[" + results.length + "] mails to download" if debug
                    LogMessage.createImportInfo results, mailbox

                    mailsToGo = results.length
                    mailsDone = 0
                
                    # for every ID, fetch the message
                    # closure, to avoid sharing variables
                    fetchOne = (i) ->
                  
                      console.log "fetching one: " + i + "/" + results.length if debug
                  
                      if i < results.length
                    
                        remoteId = results[i]
                  
                        messageFlags = []
            
                        fetch = server.fetch remoteId,
                          request:
                            body: "full"
                            headers: false

                        console.log "let's go fetching"
                        
                        fetch.on "message", (message) ->
                          parser = new mailparser.MailParser()
                          #streamAttachments: true
                          
                          parser.on "attachment", (attachment) ->
                            #attachments_all.push attachment
                            console.log "attachment found!!!"
                            
                            console.log attachment
                            
                          
                          parser.on "end", (mailParsedObject) ->
                        
                            # choose the right date
                            if mailParsedObject.headers.date
                              if mailParsedObject.headers.date.toString() == '[object Array]'
                                # if an array pick the first date
                                dateSent = new Date mailParsedObject.headers.date[0]
                              else
                                dateSent = new Date mailParsedObject.headers.date
                            else
                              dateSent = new Date()
                        
                            # compile the mail data
                            mail =
                              mailbox:      mailbox.id
                              
                              date:         dateSent.toJSON()
                              dateValueOf:  dateSent.valueOf()
                              createdAt:    new Date().valueOf()
        
                              from:         JSON.stringify mailParsedObject.from
                              to:           JSON.stringify mailParsedObject.to
                              cc:           JSON.stringify mailParsedObject.cc
                              subject:      mailParsedObject.subject
                              priority:     mailParsedObject.priority
        
                              text:         mailParsedObject.text
                              html:         mailParsedObject.html
        
                              id_remote_mailbox: remoteId
        
                              headers_raw:  JSON.stringify mailParsedObject.headers
                              # raw:          JSON.stringify mailParsedObject
                          
                              #optional parameters
                              references:   mailParsedObject.references or ""
                              inReplyTo:    mailParsedObject.inReplyTo or ""
          
                              # flags
                              flags:        JSON.stringify messageFlags
                              read:         "\\Seen" in messageFlags
                              flagged:      "\\Flagged" in messageFlags
                      
                              hasAttachments: if mailParsedObject.attachments then true else false
                          
                            console.log "attachments ***********"
                            attachments = mailParsedObject.attachments
                            console.log attachments
                            

                            # and now we can create a new mail on database, as a child of this mailbox
                            Mail.create mail, (err, mail) ->
    
                              # for now we will just skip messages which are being rejected by parser
                              # emitOnErr err
                              unless err
                              
                                # attachements
                                saveAttachments mail, attachments, ->

                                    mailbox.reload (error, mailbox) ->
                                  
                                      if error
                                        server.logout () ->
                                          console.log "Error emitted on mailbox.reload: " + error.toString() if debug
                                          server.emit "error", error
                                      else
                                    
                                        # check if we need to update the last_fetch_id index in the mailbox
                                        if mailbox.IMAP_last_fetched_id < mail.id_remote_mailbox
                                      
                                          mailbox.updateAttributes {IMAP_last_fetched_id: mail.id_remote_mailbox}, (error) ->
                                        
                                            if error
                                              server.logout () ->
                                                console.log "Error emitted on mailbox.update: " + error.toString() if debug
                                                server.emit "error", error
                                            else
                                              console.log "New highest id saved to mailbox: " + mail.id_remote_mailbox if debug
                                              mailsDone++
                                              job.progress mailsDone, mailsToGo
                                              # next iteration of our asynchronous for loop
                                              fetchOne(i + 1)
                                              # when finished
                                              if mailsToGo == mailsDone
                                                callback()
                                        else
                                          mailsDone++
                                          job.progress mailsDone, mailsToGo
                                          # next iteration of our asynchronous for loop
                                          fetchOne(i + 1)
                                          # when finished
                                          if mailsToGo == mailsDone
                                            callback()
                              else
                                console.error "Parser error - skipping this message for now: " + err.toString()
                                fetchOne(i + 1)

                          message.on "data", (data) ->
                            # on data, we feed the parser
                            parser.write data.toString()

                          message.on "end", ->
                            # additional data to store, which is "forgotten" byt the parser
                            # well, for now, we will store it on the parser itself
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
                            server.emit "error", new Error("Could not import all the mail. Retry")
                    # start the loop
                    fetchOne(0)

###
  ## Specialised function to prepare a new mailbox for import and fetching new mail
  
  # TODO : handle attachements - for now, Cozy doesn't store BLOBs...
###

Mailbox::setupImport = (callback) ->
  
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
    console.log "Connection closed (error: " + error.toString() + ")" if debug
        
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
                callback()
              else
                if debug
                    console.log "[" + results.length + "] mails to download"
                
                mailsToGo = results.length
                mailsDone = 0
                
                maxId = 0
                
                # for every ID, fetch the message
                # closure, to avoid sharing variables
                fetchOne = (i) ->
                  
                  if i < results.length
                    
                    id = results[i]
                  
                    # find the biggest ID
                    idInt = parseInt id
                    if idInt > maxId
                      maxId = idInt
                
                    mailbox.mailsToBe.create {remoteId: idInt}, (error, mailToBe) ->
                  
                      # if an error occured, emit it on server
                      if error
                        server.logout () ->
                          server.emit "error", error
                      else
                        console.log mailToBe.remoteId + " id saved successfully" if debug
                        mailsDone++
                        # job.progress mailsDone, mailsToGo
                  
                        # synchronise - all ids saved to the db
                        if mailsDone == mailsToGo
                          console.log "Finished saving ids to database; max id = " + maxId if debug
                          mailbox.updateAttributes {mailsToImport: results.length, IMAP_last_fetched_id: maxId, activated: true, importing: true}, (err) ->
                            server.logout () ->
                              callback err
                        else
                          fetchOne(i + 1)
                    
                      # TODO - timeout for a fail job (blocked or something)
                  else
                    # synchronise - all ids saved to the db
                    if mailsDone != mailsToGo
                      server.logout () ->
                      server.emit "error", new Error "Error occured - not all ids could be stored to the database"
                fetchOne(0)


###
  ## Specialised function to get as much mails as possible from ids stored previously in the database

  # TODO : handle attachements - for now, Cozy doesn't store BLOBs...
###

Mailbox::doImport = (job, callback) ->

  debug = true

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
    # debug: console.log 

  # set up lsiteners, handle errors and callback
  server.on "alert", (alert) ->
    console.log "[SERVER ALERT]" + alert

  server.on "error", (error) ->
    console.error "[ERROR]: " + error.toString()
    
    # this timeout is a walk-around for a buggy kue lib (delay doesn't work properly)
    timeToRetry = job.data.waitAfterFail or 1000 * 30
    console.error "Waiting " + timeToRetry + "ms before retry.... " + error.toString() if debug
    setTimeout () ->
      mailbox.updateAttributes {status: error.toString()}, (err) ->
        console.error "Mailbox update with error status" if debug
        LogMessage.createImportError error
        callback error
    , timeToRetry

  server.on "close", (error) ->
    console.log "Connection closed (error: " + error.toString() + ")" if debug

  emitOnErr = (error) ->
    if error
      server.logout () ->
        console.log "Error emitted on emitOnErr: " + error.toString() if debug
        server.emit "error", error
  
  # lets get the ids from the database
  MailToBe.fromMailbox mailbox, (err, mailsToBe) ->
    console.log err
    
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
                # closure, to avoid sharing variables
                fetchOne = (i) ->
                  
                  console.log "fetching one: " + i + "/" + mailsToBe.length if debug
                  
                  if i < mailsToBe.length
                    
                    mailToBe = mailsToBe[i]
                  
                    messageFlags = []
            
                    fetch = server.fetch mailToBe.remoteId,
                      request:
                        body: "full"
                        headers: false

                    fetch.on "message", (message) ->
                      parser = new mailparser.MailParser()

                      parser.on "end", (mailParsedObject) ->
                        
                        # choose the right date
                        if mailParsedObject.headers.date
                          if mailParsedObject.headers.date instanceof Array
                            # if an array pick the first date
                            dateSent = new Date mailParsedObject.headers.date[0]
                          else
                            # else take the whole thing
                            dateSent = new Date mailParsedObject.headers.date
                        else
                          dateSent = new Date()
                        
                        # compile the mail data
                        mail =
                          mailbox:      mailbox.id
                              
                          date:         dateSent.toJSON()
                          dateValueOf:  dateSent.valueOf()
                          createdAt:    new Date().valueOf()
        
                          from:         JSON.stringify mailParsedObject.from
                          to:           JSON.stringify mailParsedObject.to
                          cc:           JSON.stringify mailParsedObject.cc
                          subject:      mailParsedObject.subject
                          priority:     mailParsedObject.priority
        
                          text:         mailParsedObject.text
                          html:         mailParsedObject.html
        
                          id_remote_mailbox: mailToBe.remoteId
        
                          headers_raw:  JSON.stringify mailParsedObject.headers
                          # raw:          JSON.stringify mailParsedObject
                          
                          #optional parameters
                          references:   mailParsedObject.references or ""
                          inReplyTo:    mailParsedObject.inReplyTo or ""
          
                          # flags
                          flags:        JSON.stringify messageFlags
                          read:         "\\Seen" in messageFlags
                          flagged:      "\\Flagged" in messageFlags
                      
                          hasAttachments: if mailParsedObject.attachments then true else false

                        attachments = mailParsedObject.attachments
                        
                        # and now we can create a new mail on database, as a child of this mailbox
                        Mail.create mail, (err, mail) ->
    
                          # for now we will just skip messages which are being rejected by parser
                          # emitOnErr err
                          unless err

                            # debug info
                            console.log "New mail created : #" + mail.id_remote_mailbox + " " + mail.id + " [" + mail.subject + "] from " + JSON.stringify mail.from if debug
                        
                            saveAttachments mail, attachments, ->
                              mailToBe.destroy (error) ->
                                unless error
                              
                                  mailsDone++
                                  job.progress (mailbox.mailsToImport - (mailsToGo - mailsDone)), mailbox.mailsToImport
                              
                                  # next iteration of our asynchronous for loop
                                  fetchOne(i + 1)
                                
                                  # when finished
                                  if mailsToGo == mailsDone
                                    console.log "Success"
                                    callback()
                                else
                                  callback error
                          else
                            console.error "Parser error - skipping this message for now: " + err.toString()
                            fetchOne(i + 1)

                      message.on "data", (data) ->
                        # on data, we feed the parser
                        parser.write data.toString()

                      message.on "end", ->
                        # additional data to store, which is "forgotten" byt the parser
                        # well, for now, we will store it on the parser itself
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
                        server.emit "error", new Error("Could not import all the mail. Retry")
                # start the loop
                fetchOne(0)
