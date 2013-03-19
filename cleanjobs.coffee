Client = require('request-json').JsonClient
kue = require 'kue'
kue.app.listen 3003

client = new Client 'http://localhost:3003/'

client.get 'jobs/1..100000/', (err, res, jobs) ->
    delJobs = (jobs) ->
        if jobs.length > 0
            job = jobs.pop()
            client.del "job/#{job.id}", (err, res, body) ->
                console.log "job #{job.id} deleted"
                delJobs(jobs)
            else
                delJobs(jobs)
        else
            console.log "all jobs deleted."
            
    delJobs(jobs)
#jobs = kue.createQueue()

#jobs.active (err, jobs) ->
    #console.log err
    #console.log jobs
    
    #for job in jobs
        #console.log job.id
        
