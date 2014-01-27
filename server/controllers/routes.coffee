emails = require './emails'
folders = require './folders'
mailboxes = require './mailboxes'


module.exports =

    'mailId':
        param: emails.getMail

    'emails/:mailId':
        get: emails.show
        put: emails.update
        del: emails.destroy
    'emails/:mailId/attachments/:filename':
        get: emails.getAttachment
    'emails/rainbow/:limit/:timestamp':
        get: emails.rainbow

    'mailboxId':
        param: mailboxes.getMailbox
    'mailboxes':
        get: mailboxes.index
        post: mailboxes.create
    'mailboxes/:mailboxId':
        get: mailboxes.show
        put: mailboxes.update
        del: mailboxes.destroy
    'emails/fetch/new':
        get: mailboxes.fetchNew

    'folderId':
        param: folders.getFolder
    'folders':
        get: folders.index
    'folders/:folderId':
        get: folders.show

    'folders/:folderId/:num/:timestamp':
        get: emails.byFolder

