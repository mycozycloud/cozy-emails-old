#!/usr/bin/env coffee

app = module.exports = require('railway').createServer()

if not module.parent
    port = process.env.PORT or 8001
    app.listen port
    console.log "Railway server listening on port %d within %s environment", port, app.settings.env
    
    # setup KUE
    @kue = require 'kue'
    Job = @kue.Job
    @kue.app.listen 3003
    
    @jobs = @kue.createQueue()
    
    @jobs.on "job complete", (id) ->
      Job.get id, (err, job) ->
        return if err
        job.remove (err) ->
          throw err if err
          console.log job.data.title + " #" + job.id + " completed job removed"

    # set up CRON
    lookupNewMail = (event) =>
      job = @jobs.create("check mailboxes", {title: "Routine mail check at " + new Date().toUTCString()}).priority('high').save();
      job.on 'complete', () ->
        console.log job.data.title + " #" + job.id + " complete"
      job.on 'failed', () ->
        console.log job.data.title + " #" + job.id + " failed" 
      job.on 'progress', (progress) ->
        console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
        
    importAll = (event) =>
      job = @jobs.create("import mailbox", {title: "Routine mail check at " + new Date().toUTCString()}).priority('high').attempts(5).save();
      job.on 'complete', () ->
        console.log job.data.title + " #" + job.id + " complete"
        importAll() 
      job.on 'failed', () ->
        console.log job.data.title + " #" + job.id + " failed" 
      job.on 'progress', (progress) ->
        console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
    
    # initial check on bootup
    # lookupNewMail()
    importAll()
    # 
    @timer = setInterval lookupNewMail, 5 * 60 * 1000
  
    # KUE jobs
    @jobs.process "check mailboxes", 1, (job, done) ->
      console.log job.data.title + " #" + job.id + " job started"
      Mailbox.checkAllMailboxes done
      
    @jobs.process "import mailbox", 1, (job, done) ->
      console.log job.data.title + " #" + job.id + " job started"
      Mailbox.checkAllMailboxes done