#!/usr/bin/env coffee

app = module.exports = require('railway').createServer()

if not module.parent
    port = process.env.PORT or 8001
    app.listen port
    console.log "Railway server listening on port %d within %s environment", port, app.settings.env
    
    # setup KUE
    @kue = require 'kue'
    @kue.app.listen 3003
    
    @jobs = @kue.createQueue()
    
    # set up CRON
    lookupNewMail = (event) =>
      job = @jobs.create("check mailboxes", {title: "Routine mail check at " + new Date().toUTCString()}).priority('high').attempts(5).save();
      job.on 'complete', () ->
        console.log job.data.title + " complete" 
      job.on 'failed', () ->
        console.log job.data.title + " failed" 
      job.on 'progress', (progress) ->
        console.log job.data.title + '#' + job.id + ' ' + progress + '% complete'
      
    @timer = setInterval lookupNewMail, 60 * 1000
    
    # initial check on bootup
    lookupNewMail()
    
    # KUE jobs
    @jobs.process "check mailboxes", 1, (job, done) ->
      console.log job.data.title + " job started"
      Mailbox.checkAllMailboxes done