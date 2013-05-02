express = require 'express'
module.exports = (compound) ->
    app = compound.app

    app.configure 'production', ->
        app.use express.errorHandler()
        app.settings.quiet = true
