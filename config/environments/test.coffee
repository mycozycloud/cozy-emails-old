express = require 'express'

module.exports = (compound) ->
    app = compound.app

    app.configure 'test', ->
        app.use express.errorHandler
            dumpExceptions: true, showStack: true
        app.settings.quiet = true
