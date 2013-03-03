exports.routes = (map) ->
    map.get '/', 'mails#index'
      
    map.get '/mails/fetch-new/', 'mailboxes#fetchNew'
    map.get '/mails/:timestamp/:num/:id', 'mails#getlist'
    map.get '/mails/new/:timestamp/:id', 'mails#getnewlist'
    map.resources 'mailboxes'
    map.resources 'mails'
    
    map.get '/mailssentlist/:timestamp.:num/:id', 'mails#getlistsent'
    
    map.put '/sendmail/:id', 'mailboxes#sendmail'
    map.post '/sendmail/:id', 'mailboxes#sendmail'
    
    map.get '/mails/:id/attachments', 'mails#getattachmentslist'
    map.get '/attachments/:id/:filename', 'mails#getattachment'
    
    map.post '/logs', 'logs#savelog'
    map.delete '/logs/:id', 'logs#discard'
    map.get '/logs/:createdAt', 'logs#getactivelogs'
