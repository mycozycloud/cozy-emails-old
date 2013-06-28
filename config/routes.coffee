exports.routes = (map) ->

    # map.get '/mails/new/:timestamp/', 'mails#getnewlist'
    map.get '/mails/fetch-new/', 'mailboxes#fetchNewAll'

    map.get '/mails/:id/attachments', 'mails#getattachmentslist'
    map.get '/mails/:id/attachments/:filename', 'mails#getattachment'

    map.get '/mails/:timestamp/:num/:id', 'mails#getlist'

    map.get '/folders', 'mailboxes#folders'
    map.get '/folders/:folderId/:num/:timestamp', 'mails#byFolder'

    map.get '/mailboxes/:id/fetch-new', 'mailboxes#fetchNew'
    map.get '/mailboxes/:id/folders/:id/fetch-new',   'mailboxes#fetchFolder'

    map.resources 'mailboxes'
    map.resources 'mails'

    # map.post '/logs', 'logs#savelog'
    # map.delete '/logs/:id', 'logs#discard'
    # map.get '/logs/:createdAt', 'logs#getactivelogs'
