mails = require './mails'
folders = require './folders'
mailboxes = require './mailboxes'


module.exports =

    'mailId':
        param: mails.getMail
    'mails/:mailId':
        get: mails.show
        put: mails.update
        del: mails.destroy
    'mails/:mailId/attachments/:filename':
        get: mails.getAttachment
    'mails/rainbow/:limit/:timestamp':
        get: mails.rainbow
    'folders/:folderId/:num/:timestamp':
        get: mails.byFolder

    'mailboxId':
        param: mailboxes.getMailbox
    'mailboxes':
        get: mailboxes.index
        post: mailboxes.create
    'mailboxes/:mailboxId':
        get: mailboxes.show
        put: mailboxes.update
        del: mailboxes.destroy
    'mailboxes/:mailboxId/fetch-new':
        get: mailboxes.fetchNew

    'folderId':
        param: folders.getFolder
    'folders':
        get: folders.index
    'folders/:folderId':
        get: folders.show
