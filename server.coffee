#!/usr/bin/env coffee

###
  @file: server.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The core of the application - the railwayjs server + kue jobs to import and fetch mail.

###

kue = require 'kue'
jobs = kue.createQueue()

app = module.exports = require('railway').createServer()

if not module.parent
  port = process.env.PORT or 8003
  app.listen port
  console.log "CozyMail server listening on port %d within %s environment", port, app.settings.env
  
  # setup KUE
  @kue = require 'kue'
  @kue.app.listen 3003
  Job = @kue.Job
  @jobs = @kue.createQueue()
  
  app.jobs = @jobs

##  - CREATECHECKJOB - 
## CHECK FOR NEW MAILS IN THE MAILBOX
  app.createCheckJob = (mailboxId, callback) =>
    
    jobs = @jobs
    lastProgress = -1
    
    # get the mailbox
    Mailbox.find mailboxId, (error, mailbox) ->
      if error
        console.error "Check error.... The mailbox doesn't exist"
      else          
        job = jobs.create("check mailbox",
          mailboxId: mailboxId
          title: "Check of " + mailbox.name
        )
        .save()
        
        # callback - job saved (a priori)
        callback() if callback?

        # on import complete
        job.on 'complete', () ->
          console.log job.data.title + " #" + job.id + " complete at " + new Date().toUTCString()
          mailbox.updateAttributes {IMAP_last_fetched_date: new Date()}, (error) ->
            unless error
              console.log "Check successful !"
            else
              console.error "Check error...."

        # on import failed
        job.on 'failed', () ->
          console.log job.data.title + " #" + job.id + " failed at " + new Date().toUTCString()
          mailbox.updateAttributes {status: "Mail check failed."}, (error) ->
            console.error "Mail check failed."

        # on import progress
        job.on 'progress', (progress) ->
          if progress != lastProgress
            console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'

##  - CREATECHECKJOB - PROCESS 

  @jobs.process "check mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    Mailbox.find job.data.mailboxId, (error, mailbox) ->
      if error
        done error
      else
        mailbox.getNewMail job, done

  # CRON job
  app.createCheckJobs = =>
    console.log "Creating check jobs"
    Mailbox.all {where: {activated: true}}, (err, mailboxes) ->
      for mailbox in mailboxes
        app.createCheckJob mailbox.id
        
  # set-up CRON
  setInterval app.createCheckJobs, 1000 * 60 * 5

##  - CREATECHECKJOB - END

  
##  - CREATEIMPORTJOB - 
## IMPORT A NEW MAILBOX
  app.createImportJob = (mailboxId) =>
    
    jobs = @jobs
    lastProgress = -1
    
    # get the mailbox
    Mailbox.find mailboxId, (error, mailbox) ->
      if error
        console.error "Import error.... The mailbox doesn't exist"
      else
      
        # perform a setup
        mailbox.setupImport (error) ->
          
          if error
            mailbox.updateAttributes {imported: false, status: "Could not prepare the import."}, (error) ->
                console.error "Could not prepare the import. Aborting."
          else 
          
            job = jobs.create("import mailbox",
              mailboxId: mailboxId
              title: "Import of " + mailbox.name
              waitAfterFail: 1000 * 60  # if fails, wait before next try 
            )
            .attempts(9999)  # on reessaie
            .save()
    
            # on import complete
            job.on 'complete', () ->
              console.log job.data.title + " #" + job.id + " complete at " + new Date().toUTCString()
              # get the mailbox
              Mailbox.find job.data.mailboxId, (error, mailbox) ->
                if error
                  console.error "Import error.... The mailbox doesn't exist anymore"
                else
                  # and update the status
                  mailbox.updateAttributes {imported: true, status: "Import successful !"}, (error) ->
                    unless error
                      console.log "Import successful !"
                    else
                      console.error "Import error...."

            # on import failed
            job.on 'failed', () ->
              console.log job.data.title + " #" + job.id + " failed at " + new Date().toUTCString()
              # get the mailbox
              Mailbox.find job.data.mailboxId, (error, mailbox) ->
                if error
                  console.error "Import error.... The mailbox doesn't exist anymore"
                else
                  # and update the status
                  mailbox.updateAttributes {imported: false, importing: false, activated: false}, (error) ->
                    console.error "Import failed !"
    
            # on import progress
            job.on 'progress', (progress) ->
              if progress != lastProgress
                console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
                # get the mailbox
                Mailbox.find job.data.mailboxId, (error, mailbox) ->
                  if error
                    console.log "Import error.... The mailbox doesn't exist anymore"
                  else
                    lastProgress = progress
                    mailbox.updateAttributes {status: "Import " + progress + " %"}, (error) ->
                      if error
                        console.error "Error trying to update attributes: " + error.toString()

##  - CREATEIMPORTJOB - JOB PROCESS

  @jobs.process "import mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    Mailbox.find job.data.mailboxId, (error, mailbox) ->
      if error
        done error
      else
        mailbox.doImport job, done

##  - CREATEIMPORTJOB - END

  # debug
  @jobs.promote()