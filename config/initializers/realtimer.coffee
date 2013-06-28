module.exports = (compound) ->

    Realtimer = require 'cozy-realtime-adapter'

    Realtimer compound, ['logmessage.*', 'mail.*', 'mailbox.*']
