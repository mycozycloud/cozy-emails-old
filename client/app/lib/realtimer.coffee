{Mailbox} = require 'models/mailbox'
{Email} = require 'models/email'
{Folder} = require 'models/folder'
{EmailView} = require 'views/mails_list_element'

module.exports = class SocketListener extends CozySocketListener

    models:
        'mailbox' : Mailbox
        'folder'  : Folder
        'email'   : Email

    events:
        ['mailbox.create', 'mailbox.update', 'mailbox.delete',
         'folder.create', 'folder.update', 'folder.delete',
         'email.create', 'email.update', 'email.delete']

    onRemoteCreate: (model) ->
        if model instanceof Mailbox
            app.mailboxes.add model

        else if model instanceof Folder
            app.folders.add model

        if model instanceof Email
            if app.mails.folderId is 'rainbow' \
            or app.mails.folderId is model.get 'folder'
                app.mails.add model

    onRemoteDelete: (model) ->
        #model.trigger 'destroy', model, model.collection, {}
