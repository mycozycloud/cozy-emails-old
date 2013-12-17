module.exports = (app) ->
    Realtimer = require 'cozy-realtime-adapter'
    Realtimer app, ['logmessage.*', 'mail.*', 'mailbox.*', 'mailfolder.*']
