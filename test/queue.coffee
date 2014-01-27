should = require 'should'
queue = require '../server/lib/queue'

counter = 0
queue = queue()

describe 'queue execution', ->

    it 'when I add a task to the queue', ->
        queue.push (queue, done) ->
            counter += 1
            done()
        , false
        queue.push (queue, done) ->
            counter += 2
            done()
        , false

    it 'it should appear in the execution line', ->
        queue.size().should.equal 2

    it 'When I run the queue', (done) ->
        queue.run done

    it 'it should run the tasks', ->
        counter.should.equal 3
