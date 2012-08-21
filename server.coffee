#!/usr/bin/env coffee

app = module.exports = require('railway').createServer()

if not module.parent
  
  port = process.env.PORT or 8001
  app.listen port
  console.log "CozyMail server listening on port %d within %s environment", port, app.settings.env
  
  # setup KUE
  @kue = require 'kue'
  @kue.app.listen 3003
  Job = @kue.Job
  @jobs = @kue.createQueue()
  
  @jobs.on "job complete", (id) ->
    Job.get id, (error, job) ->
      return if error
      job.remove (err) ->
        throw err if err
        console.log job.data.title + " #" + job.id + " complete job removed"

# BUILD JOBS

## PERIODICAL MAIL CHECK

  createCheckJob = (mailbox) =>
    job = @jobs.create("check mailbox",
      mailbox: mailbox
      num: 250
      title: "Check of " + mailbox + " at " + new Date().toUTCString()
    ).save()
     
    job.on 'complete', () ->
      console.log job.data.title + " #" + job.id + " complete"
    job.on 'failed', () ->
      console.log job.data.title + " #" + job.id + " failed"
    job.on 'progress', (progress) ->
      console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
  
  createCheckJobs = =>
    Mailbox.all {where: {activated: true}}, (err, mailboxes) ->
      for mailbox in mailboxes
        createCheckJob mailbox
  
  # set-up CRON
  setInterval createCheckJobs, 1000 * 60 * 1
  createCheckJobs()
  
## IMPORT A NEW MAILBOX

  createImportJob = (mailbox) =>
    job = @jobs.create("import mailbox",
      mailbox: mailbox
      title: "Import of " + mailbox + " at " + new Date().toUTCString()
    ).save()
   
    job.on 'complete', () ->
      console.log job.data.title + " #" + job.id + " complete"
    job.on 'failed', () ->
      console.log job.data.title + " #" + job.id + " failed"
    job.on 'progress', (progress) ->
      console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'

  createImportJobs = =>
    Mailbox.all {where: {activated: false}}, (err, mailboxes) ->
      for mailbox in mailboxes
        createImportJob mailbox

  setInterval createImportJobs, 1000 * 60 * 1
  createImportJobs()
        
        
  # KUE jobs
  @jobs.process "check mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started"
    (Mailbox job.data.mailbox).getNewMail job.data.num, done, job, "asc"
    
  @jobs.process "import mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started"
    if job.data.mailbox.activated == false
      (Mailbox job.data.mailbox).getAllMail done, job
    else
      console.log "Skipping - already imported"
      done()