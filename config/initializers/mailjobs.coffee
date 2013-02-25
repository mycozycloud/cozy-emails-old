@kue = require 'kue'
#@kue.app.listen 3003

Job = @kue.Job
@jobs = @kue.createQueue()
app.jobs = @jobs
                    

# helpers

logStarted = (job) ->
    msg = "#{job.data.title} # #{job.id} started at "
    msg += new Date().toUTCString()
    console.log msg

logComplete = (job) ->
    msg = "#{job.data.title} # #{job.id} complete at "
    msg += new Date().toUTCString()
    console.log msg

logFailed = (job) ->
    msg = "#{job.data.title} # #{job.id} failed at "
    msg += new Date().toUTCString()
    console.log msg

logProgress = (job, progress) ->
    msg = "#{job.data.title} # #{job.id} "
    msg += "#{progress} % complete"
    console.log msg


## JOB 1 : check for new mails for given mailbox

# Define Job
@jobs.process "check mailbox", 1, (job, done) ->
    logStarted job

    Mailbox.find job.data.mailboxId, (err, mailbox) ->
        if error or not mailbox
            done err
        else
            mailbox.getNewMail job, done


# Job configuration + job start
app.createCheckJob = (mailboxId, callback) =>

    jobs = @jobs
    lastProgress = -1
    
    Mailbox.find mailboxId, (err, mailbox) ->
        if err or not mailbox?
            console.error "Check error... The mailbox doesn't exist"
            callback err if callback?
        else
            job = jobs.create "check mailbox",
                mailboxId: mailboxId
                title: "Check of #{mailbox.name}"
            .save()
            
            callback() if callback?
            
            job.on 'complete', () ->
                logComplete job
                mailbox.fetchFinished (err) ->
                    if err
                        mailbox.log "Check error..."
                    else
                        mailbox.log "Check successful !"

            job.on 'failed', () ->
                logFailed job
                mailbox.fetchFailed (error) ->
                    mailbox.log "Mail check failed."

            job.on 'progress', (progress) ->
                logProgress job, progress if progress isnt lastProgress

app.createCheckJobs = =>
    console.log "Creating check jobs..."
    Mailbox.all (err, mailboxes) ->
        if mailboxes?.length > 0
            app.createCheckJob(mailbox.id) for mailbox in mailboxes
            
# set-up CRON
setInterval app.createCheckJobs, 1000 * 60 * 4 # check every 4 minutes

# launch on startup
app.createCheckJobs()


## JOB 2 : import a whole box

# Define Job
@jobs.process "import mailbox", 1, (job, done) ->
    logStarted job

    Mailbox.find job.data.mailboxId, (error, mailbox) ->
        if err
            done err
        else
            mailbox.doImport job, done

# Job launcher
app.createImportJob = (mailboxId) =>
    
    jobs = @jobs
    lastProgress = -1
    lastTenProgress = 0
    
    createJobs = (mailbox) ->
        job = jobs.create "import mailbox",
            mailboxId: mailbox.id
            title: "Import of #{mailbox.name}"
            waitAfterFail: 1000 * 60
        .save()
        .attempts(9999)
        
        LogMessage.createImportStartedInfo mailbox

        job.on 'complete', ->
            logComplete job
            mailbox.importSuccessfull (error) ->
                if error
                    mailbox.log "Import error..."
                else
                    mailbox.log "Import successful !"

        job.on 'failed', ->
            logFailed job
            mailbox.importFailed (error) ->
                mailbox.log "Import failed...."

        job.on 'progress', (progress) ->
            if progress isnt lastProgress
                logProgress job, progress

                lastProgress = progress
                if progress > lastTenProgress + 10
                    lastTenProgress += 10
                    mailbox.progress progress, (error) ->
                        console.error error if error
                        

    Mailbox.find mailboxId, (err, mailbox) ->
        if error or not mailbox?
            console.error "Import error... The mailbox doesn't exist"
        else
            mailbox.setupImport (err) ->
                if err
                    mailbox.importError ->
                        mailbox.log "Could not prepare the import. Aborting."
                else
                    createJobs mailbox
