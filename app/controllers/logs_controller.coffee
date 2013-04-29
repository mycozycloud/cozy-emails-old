###
    @file: logs_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller for logs system - displaying system information in the
        interface
###

load 'application'

before ->
    LogMessage.find req.params.id, (err, logMessage) =>
        if err or !logMessage
            send 404
        else
            @logMessage = logMessage
            next()
, only: ['discard']


# POST '/logs' Create a new log.
action 'savelog', ->
    data = {}
    attrs = [
        "type",
        "text",
        "createdAt",
        "timeout"
    ]

    for attr in attrs
        data.attr = body.attr

    if data["timeout"] is 0
        LogMessage.create data, (err, logMessage) =>
            if err or not logMessage
                send 500
            else
                send 201
    else
        send 200


# DELETE '/logs/:id' Delete given log.
action 'discard', ->
    @logMessage.destroy (error) =>
        if not error
            send 200
        else
            send 500


# GET '/logs/:createdAt' Get logs from given date
action 'getactivelogs', ->
    if req.params.createdAt isnt 0 then skip = 1 else skip = 0

    params =
        startkey: Number req.params.createdAt
        skip: 0
        descending: false

    LogMessage.request "date", params, (err, logs) =>
        if err
            send 500
        else
            for log in logs
                log.destroy() if log.timeout isnt 0

            send logs
