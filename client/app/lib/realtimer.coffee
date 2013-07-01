{Mailbox} = require 'models/mailbox'
{Mail} = require 'models/mail'
{Folder} = require 'models/folder'

module.exports = class SocketListener extends CozySocketListener

    models:
        'mailbox' : Mailbox
        'folder'  : Folder
        'mail'    : Mail

    events:
        ['mailbox.create', 'mailbox.update', 'mailbox.delete',
        'folder.create', 'folder.update', 'folder.delete',
        'mail.create', 'mail.update', 'mail.delete']

    onRemoteCreate: (model) ->
        if model instanceof Mailbox
            app.mailboxes.add model

        else if model instanceof Folder
            app.folders.add model

        if model instanceof Mail and app.mails.folderId is model.folder
            app.mails.add model

    onRemoteDelete: (model) ->
        model.trigger 'destroy', model, model.collection, {}
