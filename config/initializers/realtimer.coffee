module.exports = (compound) ->

    Realtimer = require 'cozy-realtime-adapter'

    a = Realtimer compound, ['logmessage.*', 'mail.*', 'mailbox.*', 'mailfolder.*']
