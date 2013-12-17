mails = require './mails'
folders = requires './folders'


module.exports =


    'mailId':
        param: mailbs.getMail
    'mails/:mailId':
        get: mails.show
        update: mails.update
        destroy: mails.destroy
    'mails/:mailId/attachments/:filename':
        get: mails.getattachment
    'mails/rainbow/:limit/:timestamp':
        get: mails.rainbow
    'folders/:folderId/:num/:timestamp':
        get: mails.byFolder

    'mailboxId':
        param: mailboxes.getFolder
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
