module.exports = (app) ->
    Realtimer = require 'cozy-realtime-adapter'
    Realtimer app, ['logmessage.*', 'email.*', 'mailbox.*', 'mailfolder.*']
