{Mailbox} = require 'models/mailbox'
{Mail} = require 'models/mail'

module.exports = class SocketListener extends CozySocketListener

    models:
        'mailbox' : Mailbox
        'mail'    : Mail

    events:
        ['mailbox.create', 'mailbox.update', 'mailbox.delete',
        'mail.create', 'mail.update', 'mail.delete']

    onRemoteCreate: (model) ->
        @collections[0].add model if model instanceof Mailbox
        @collections[1].add model if model instanceof Mail

    onRemoteDelete: (model) ->
        model.trigger 'destroy', model, model.collection, {}
