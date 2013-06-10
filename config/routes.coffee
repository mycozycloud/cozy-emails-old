exports.routes = (map) ->

    map.get '/mails/fetch-new/', 'mailboxes#fetchNew'
    map.get '/mails/new/:timestamp/', 'mails#getnewlist'
    map.get '/mails/:id/attachments', 'mails#getattachmentslist'
    map.get '/mails/:timestamp/:num/:id', 'mails#getlist'
    map.resources 'mailboxes'
    map.resources 'mails'

    map.get '/attachments/:id/:filename', 'mails#getattachment'

    map.post '/logs', 'logs#savelog'
    map.delete '/logs/:id', 'logs#discard'
    map.get '/logs/:createdAt', 'logs#getactivelogs'
