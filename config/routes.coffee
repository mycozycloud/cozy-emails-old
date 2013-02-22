exports.routes = (map) ->
    map.get '/', 'mails#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
    map.get '/mailslist/:timestamp.:num/:id', 'mails#getlist'
    map.get '/mails/new/:timestamp/:id', 'mails#getnewlist'
    
    map.get '/mailssentlist/:timestamp.:num/:id', 'mails#getlistsent'
    
    map.put '/sendmail/:id', 'mailboxes#sendmail'
    map.post '/sendmail/:id', 'mailboxes#sendmail'
    
    map.get '/importmailbox/:id', 'mailboxes#import'
    map.get '/fetchmailbox/:id', 'mailboxes#fetch'
    map.get '/fetchmailboxandwait/:id', 'mailboxes#fetchandwait'

    map.get '/mails/:id/attachments', 'mails#getattachmentslist'
    map.get '/attachments/:id/:filename', 'mails#getattachment'
    
    map.post '/logs', 'logs#savelog'
    map.delete '/logs/:id', 'logs#discard'
    map.get '/logs/:createdAt', 'logs#getactivelogs'
