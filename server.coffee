#!/usr/bin/env coffee
app = module.exports = (params) ->
    params = params || {}
    params.root = params.root || __dirname
    return require('compound').createServer params

if not module.parent
    port = process.env.PORT or 9203
    host = process.env.HOST or "127.0.0.1"
    server = app()

    server.listen port, host, ->
        console.log(
            "Compound server listening on %s:%d within %s environment",
            host, port, server.set 'env')
