if process.env isnt "test"
    @kue = require 'kue'

    Job = @kue.Job
    @jobs = @kue.createQueue()
    app.jobs = @jobs
                        

    # helpers

    logStarted = (job) ->
        msg = "#{job.type} # #{job.id} started at "
        msg += new Date().toUTCString()
        console.log msg

    logComplete = (job) ->
        msg = "#{job.type} # #{job.id} complete at "
        msg += new Date().toUTCString()
        console.log msg

    logFailed = (job) ->
        msg = "#{job.type} # #{job.id} failed at "
        msg += new Date().toUTCString()
        console.log msg

    logProgress = (job, progress) ->
        msg = "#{job.type} # #{job.id} "
        msg += "#{progress} % complete"
        console.log msg


    ## JOB 1 : check for new mails for given mailbox

    # Define Job
    @jobs.process "check mailbox", 1, (job, done) ->
        logStarted job

        Mailbox.find job.data.mailboxId, (err, mailbox) ->
            if err or not mailbox
                done err
            else
                mailbox.getNewMail 250, job, done


    # Job configuration + job start
    app.createCheckJob = (mailboxId, callback) =>
        jobs = @jobs
        lastProgress = -1
        
        Mailbox.find mailboxId, (err, mailbox) ->
            if err or not mailbox?
                console.error "Check error... The mailbox doesn't exist"
                callback err if callback?
            else if not mailbox.imported
                mailbox.log 'No mail check, the mailbox is not fully imported'
                callback() if callback?
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
                        job.remove (err) ->
                            console.log err if err
                            console.log "removed completed job ##{job.id}"

                job.on 'failed', () ->
                    logFailed job
                    job.remove (err) ->
                        console.log err if err
                        console.log "removed completed job ##{job.id}"
                        mailbox.fetchFailed (err) ->
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

        Mailbox.find job.data.mailboxId, (err, mailbox) ->
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
            .attempts(5)
            
            LogMessage.createImportStartedInfo mailbox

            job.on 'complete', ->
                logComplete job
                mailbox.importSuccessfull (err) ->
                    if err
                        mailbox.log "Import error..."
                    else
                        mailbox.log "Import successful !"
                    job.remove (err) ->
                        console.log err if err
                        console.log "removed completed job ##{job.id}"

            job.on 'failed', ->
                logFailed job
                job.remove (err) ->
                    console.log err if err
                    console.log "removed completed job ##{job.id}"
                    mailbox.importFailed (err) ->
                        mailbox.log "Import failed...."

            job.on 'progress', (progress) ->
                if progress isnt lastProgress
                    logProgress job, progress

                    lastProgress = progress
                    if progress > lastTenProgress + 10
                        lastTenProgress += 10
                        mailbox.progress progress, (err) ->
                            console.error err if err
                            

        Mailbox.find mailboxId, (err, mailbox) ->
            if err or not mailbox?
                console.error "Import error... The mailbox doesn't exist"
            else
                mailbox.setupImport (err) ->
                    if err
                        mailbox.importError ->
                            mailbox.log "Could not prepare the import. Aborting."
                    else
                        createJobs mailbox


    ## JOB 3 : Clean jobs

    # Define Job
    @jobs.process "clean jobs", 1, (job, done) =>
        logStarted job

        now = new Date()
        now.setHours(now.getHours() - 24)
        @jobs.active (err, jobs) =>
            for job in jobs
                if job.created_at <= now and
                (job.type is "check mailbox" or job.type is "import mailbox")
                    job.remove()
            @jobs.failed (err, jobs) =>
                for job in jobs
                    if job.type is "check mailbox" or
                    job.type is "import mailbox"
                        job.remove()
                @jobs.inactive (err, jobs) ->
                    if job.type is "check mailbox" or
                    job.type is "import mailbox"
                        job.remove()
        done()

    createCleanJob = =>

        job = @jobs.create("clean jobs", {}).save()
            
        job.on 'complete', () ->
            logComplete job
            job.remove (err) ->
                console.log err if err
                console.log "removed completed job ##{job.id}"

        job.on 'failed', () ->
            logFailed job
            job.remove (err) ->
                console.log err if err
                console.log "removed completed job ##{job.id}"

    createCleanJob()
    setInterval createCleanJob, 1000 * 60 * 60 # clean every hour
