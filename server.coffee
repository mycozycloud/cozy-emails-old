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
  
  # @jobs.on "job complete", (id) ->
  #   Job.get id, (error, job) ->
  #     return if error
  #     job.remove (err) ->
  #       throw err if err
  #       console.log job.data.title + " #" + job.id + " complete job removed"

# BUILD JOBS

## PERIODICAL MAIL CHECK

  createCheckJob = (mailbox) =>
    job = @jobs.create("check mailbox",
      mailbox: mailbox
      num: 250
      title: "Check of " + mailbox.name
    ).save()
     
    job.on 'complete', () ->
      console.log job.data.title + " #" + job.id + " complete"
    job.on 'failed', () ->
      console.log job.data.title + " #" + job.id + " failed"
    job.on 'progress', (progress) ->
      console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
  
  createCheckJobs = =>
    console.log "createCheckJobs"
    Mailbox.all {where: {activated: true}}, (err, mailboxes) ->
      for mailbox in mailboxes
        createCheckJob mailbox
  
  # set-up CRON
  setInterval createCheckJobs, 1000 * 60 * 0.5
  createCheckJobs()
  
## IMPORT A NEW MAILBOX

  createImportJob = (mailbox) =>
    job = @jobs.create("import mailbox",
      mailbox: mailbox
      title: "Import of " + mailbox.name
    ).attempts(999).save()
    
    lastProgress = 0
    
    job.on 'complete', () ->
      console.log job.data.title + " #" + job.id + " complete at " + new Date().toUTCString()
      mailbox.updateAttributes {imported: true}, (error) ->
        unless error
          console.log "Import successful !"
        else
          console.log "Import error...."

    job.on 'failed', () ->
      console.log job.data.title + " #" + job.id + " failed at " + new Date().toUTCString()
      mailbox.mails.destroyAll () ->
        mailbox.updateAttributes {imported: false, importing: false, activated: false}, (error) ->
          console.log "Import failed !"
    
    job.on 'progress', (progress) ->
      if progress != lastProgress
        console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
        lastProgress = progress
      
  createImportJobs = =>
    console.log "createImportJobs"
    Mailbox.all {where: {imported: false, importing: false}}, (err, mailboxes) ->
      for mailbox in mailboxes
        createImportJob mailbox

  setInterval createImportJobs, 1000 * 60 * 0.5
  createImportJobs()
        
        
  # KUE jobs
  @jobs.process "check mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    (Mailbox job.data.mailbox).getNewMail job.data.num, done, job, "asc"
    
  @jobs.process "import mailbox", 3, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    (Mailbox job.data.mailbox).getAllMail done, job
