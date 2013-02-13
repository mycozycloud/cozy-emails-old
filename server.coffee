#!/usr/bin/env coffee

###
    @file: server.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        The core of the application - the railwayjs server + kue jobs to import and fetch mail.

###

kue = require 'kue'
jobs = kue.createQueue()

app = module.exports = require('railway').createServer()

if not module.parent
    port = process.env.PORT or 9203
    app.listen port, "127.0.0.1"
    console.log "Cozy Mail server listening on port %d within %s environment", port, app.settings.env
