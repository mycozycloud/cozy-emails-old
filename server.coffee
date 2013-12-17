americano = require 'americano'
initMailboxes = require './server/initializers/mailboxes'
setupRealtime = require './server/initializers/realtime'


process.on 'uncaughtException', (err) ->
    console.error err
    console.error err.stack

port = process.env.PORT || 9282
americano.start name: 'Cozy Mails', port: port, (app, server) ->
    app.server = server
    setupRealtime app

    if process.env.NODE_ENV isnt "test"
        initMailboxes()

