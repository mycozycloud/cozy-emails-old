#!/usr/bin/env coffee
kue = require 'kue'
jobs = kue.createQueue()

app = module.exports = require('railway').createServer()

if not module.parent
  port = process.env.PORT or 8003
  app.listen port
  console.log "CozyMail server listening on port %d within %s environment", port, app.settings.env
  
  # setup KUE
  #@kue = require 'kue'
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
  setInterval app.createCheckJobs, 1000 * 60 * 5
  app.createCheckJobs()
  
## IMPORT A NEW MAILBOX

  app.createImportJob = (mailbox) =>
    
    if mailbox.imported == false and mailbox.importing == false
      
      job = @jobs.create("import mailbox",
        mailbox: mailbox
        title: "Import of " + mailbox.name
      ).save()
      #.attempts(999).save()
    
      lastProgress = -1
    
      job.on 'complete', () ->
        console.log job.data.title + " #" + job.id + " complete at " + new Date().toUTCString()
        mailbox.updateAttributes {imported: true, status: "Import successful !"}, (error) ->
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
          mailbox.updateAttributes {status: "Import " + progress + " %"}, (error) ->
            if error
              console.log "Error trying to update attributes: " + error.toString()
      
  app.createImportJobs = =>
    console.log "createImportJobs"
    Mailbox.all {where: {imported: false, importing: false}}, (err, mailboxes) ->
      for mailbox in mailboxes
        app.createImportJob mailbox

  # check for forgotten, unimported jobs every 7 minutes
  setInterval app.createImportJobs, 1000 * 60 * 7
        
  # KUE jobs
  @jobs.process "check mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    (Mailbox job.data.mailbox).getNewMail job.data.num, done, job, "asc"
    
  @jobs.process "import mailbox", 3, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    (Mailbox job.data.mailbox).getAllMail done, job
