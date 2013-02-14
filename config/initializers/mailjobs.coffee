# setup KUE
@kue = require 'kue'

#@kue.app.listen 3003
Job = @kue.Job
@jobs = @kue.createQueue()
  
app.jobs = @jobs


## - CREATECHECKJOB -
## CHECK FOR NEW MAILS IN THE MAILBOX
app.createCheckJob = (mailboxId, callback) =>

    jobs = @jobs
    lastProgress = -1
    
    # get the mailbox
    Mailbox.find mailboxId, (error, mailbox) ->
        if error
            console.error "Check error.... The mailbox doesn't exist"
        else
            job = jobs.create "check mailbox",
                mailboxId: mailboxId
                title: "Check of #{mailbox.name}"
            .save()
            
            callback() if callback?
            
            job.on 'complete', () ->
                msg = "#{job.data.title} # #{job.id} complete at "
                msg += new Date().toUTCString()
                console.log msg
                
                mailbox.fetchFinished (error) ->
                    unless error
                        console.log "Check successful !"
                    else
                        console.error "Check error...."

            job.on 'failed', () ->
                msg = "#{job.data.title} # #{job.id} failed at "
                msg += new Date().toUTCString()
                console.log msg
                
                mailbox.fetchFailed (error) ->
                    console.error "Mail check failed."

            job.on 'progress', (progress) ->
                if progress isnt lastProgress
                    msg = "#{job.data.title} # #{job.id} "
                    msg += "#{progress} % complete"
                    console.log msg
                    
## - CREATECHECKJOB - PROCESS

@jobs.process "check mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " + new Date().toUTCString()
    Mailbox.find job.data.mailboxId, (error, mailbox) ->
        if error or not mailbox
            done error
        else
            mailbox.getNewMail job, done

# CRON job
app.createCheckJobs = =>
    console.log "Creating check jobs..."
    Mailbox.all {where: {activated: true}}, (err, mailboxes) ->
        for mailbox in mailboxes
            app.createCheckJob mailbox.id
            
# set-up CRON
setInterval app.createCheckJobs, 1000 * 60 * 4 # check every 4 minutes
# launch on startup
app.createCheckJobs()

## - CREATECHECKJOB - END


## - CREATEIMPORTJOB -
## IMPORT A NEW MAILBOX
app.createImportJob = (mailboxId) =>
    
    jobs = @jobs
    lastProgress = -1
    lastTenProgress = 0
    
    # get the mailbox
    Mailbox.find mailboxId, (error, mailbox) ->
        if error
            console.error "Import error.... The mailbox doesn't exist"
        else
        
            # perform a setup
            mailbox.setupImport (error) ->
                if error
                    data =
                        imported: false
                        status: "Could not prepare the import."

                    mailbox.updateAttributes data, (error) ->
                        console.error "Could not prepare the import. Aborting."
                        LogMessage.createImportPreparationError mailbox
                else
                    job = jobs.create "import mailbox",
                        mailboxId: mailboxId
                        title: "Import of " + mailbox.name
                        waitAfterFail: 1000 * 60
                    .attempts 9999 # on reessaie
                    .save()
                    
                    LogMessage.createImportStartedInfo mailbox
    
                    # on import complete
                    job.on 'complete', () ->
                        console.log job.data.title + " #" + job.id + " complete at " + new Date().toUTCString()
                        # get the mailbox
                        Mailbox.find job.data.mailboxId, (error, mailbox) ->
                            if error
                                console.error "Import error.... The mailbox doesn't exist anymore"
                            else
                                LogMessage.createImportSuccess mailbox
                                    
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
                                LogMessage.createBoxImportError mailbox

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
                                    
                                    if progress > lastTenProgress + 10
                                        
                                        lastTenProgress += 10
                                        LogMessage.createImportProgressInfo mailbox, progress
                                            
                                    mailbox.updateAttributes {status: "Import " + progress + " %"}, (error) ->
                                        if error
                                            console.error "Error trying to update attributes: " + error.toString()

## - CREATEIMPORTJOB - JOB PROCESS

@jobs.process "import mailbox", 1, (job, done) ->
    console.log job.data.title + " #" + job.id + " job started at " +
                new Date().toUTCString()
    Mailbox.find job.data.mailboxId, (error, mailbox) ->
        if error
            done error
        else
            mailbox.doImport job, done

## - CREATEIMPORTJOB - END
