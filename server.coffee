#!/usr/bin/env coffee
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
  
  # @jobs.on "job complete", (id) ->
  #   Job.get id, (error, job) ->
  #     return if error
  #     job.remove (err) ->
  #       throw err if err
  #       console.log job.data.title + " #" + job.id + " complete job removed"

# BUILD JOBS

## PERIODICAL MAIL CHECK

  app.createCheckJob = (mailbox, callback) =>
    job = @jobs.create("check mailbox",
      mailbox: mailbox
      num: 250
      title: "Check of " + mailbox.name
    ).save()
     
    job.on 'complete', () ->
      console.log job.data.title + " #" + job.id + " complete"
      callback() if callback?
    job.on 'failed', () ->
      console.log job.data.title + " #" + job.id + " failed"
      callback "error" if callback?
    job.on 'progress', (progress) ->
      console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
  
  app.createCheckJobs = =>
    console.log "createCheckJobs"
    Mailbox.all {where: {activated: true}}, (err, mailboxes) ->
      for mailbox in mailboxes
        app.createCheckJob mailbox
        
  # set-up CRON
  # setInterval app.createCheckJobs, 1000 * 60 * 5
  # app.createCheckJobs()
  
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

##  - CREATEIMPORTJOB - END
      
  # app.createContinueImportJobs = =>
  #   console.log "createContinueImportJobs"
  #   Mailbox.all {where: {imported: false, importing: false}}, (err, mailboxes) ->
  #     for mailbox in mailboxes
  #       app.createImportJob mailbox.id

  # check for forgotten, unimported jobs every 7 minutes
  # setInterval app.createContinueImportJobs, 1000 * 60 * 7
  
  @jobs.promote()


  @jobs.process "import mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    Mailbox.find job.data.mailboxId, (error, mailbox) ->
      if error
        done error
      else
        mailbox.doImport job, done
