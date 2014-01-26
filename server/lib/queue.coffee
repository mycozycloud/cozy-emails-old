events = require 'events'
log = require('printit')
    date: true
    prefix: 'mail queue'

class Queue extends events.EventEmitter

    constructor: ->
        @queue = []

    push: (task, run=true) ->
        @queue.push task
        @run() if run and not @isRunning

    get: (index) ->
        @queue[index]

    run: (callback) ->
        @emit 'start'
        @isRunning = true
        execTask = =>
            if @size() > 0
                task = @queue.pop()
                task @, (err) =>
                    if err
                        @isRunning = false
                        @emit 'error'
                        callback err
                    else
                        process.nextTick execTask
            else
                @isRunning = false
                @emit 'end'
                callback()
        execTask()

    size: =>
        @queue.length

    empty: =>
        @queue = []


module.exports = ->
    return new Queue()
