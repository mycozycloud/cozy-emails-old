#!/usr/bin/env coffee
kue = require 'kue'
jobs = kue.createQueue()

app = module.exports = require('railway').createServer()

if not module.parent
    port = process.env.PORT or 8003
    app.listen port
    console.log "Railway server listening on port %d within %s environment", port, app.settings.env
    
    # setup KUE
    Job = kue.Job
    
    
# BUILD JOBS

    createCheckJob = (mb, delay=0, callback) =>
      job = jobs.create("check mailbox",
        mailbox: mb
        num: 250
        title: "Check of " + mb + " at " + new Date().toUTCString()
      ).delay(delay).save(callback)
       
      job.on 'complete', () ->
        console.log job.data.title + " #" + job.id + " complete"
        createCheckJob mb, 1000 * 60 * 0.5
      job.on 'failed', () ->
        console.log job.data.title + " #" + job.id + " failed"
        createCheckJob mb, 1000 * 60 * 1
      job.on 'progress', (progress) ->
        console.log job.data.title + ' #' + job.id + ' ' + progress + '% complete'
        
    createCheckJobs = =>
      Mailbox.all (err, mbs) =>
        for mb in mbs
          createCheckJob mb, 1000 * 0.5
          
          
    # set-up CRON
    createCheckJobs()
    
    jobs.promote()

    # KUE jobs
    jobs.process "check mailbox", 1, (job, done) ->
      console.log job.data.title + " #" + job.id + " job started"
      (Mailbox job.data.mailbox).getNewMail job.data.num, done

