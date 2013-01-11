exports.routes = (map) ->
    map.get '/', 'mails#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
    map.get '/mailslist/:timestamp.:num/:id', 'mails#getlist'
    map.get '/mailsnew/:timestamp/:id', 'mails#getnewlist'
    
    map.get '/mailssentlist/:timestamp.:num/:id', 'mails#getlistsent'
    
    map.put '/sendmail/:id', 'mailboxes#sendmail'
    map.post '/sendmail/:id', 'mailboxes#sendmail'
    
    map.get '/importmailbox/:id', 'mailboxes#import'
    map.get '/fetchmailbox/:id', 'mailboxes#fetch'
    map.get '/fetchmailboxandwait/:id', 'mailboxes#fetchandwait'

    map.get '/getattachments/:id', 'mails#getattachmentslist'
    map.get '/getattachment/:attachment', 'mails#getattachment'
    
    map.get '/getlogs/:createdAt', 'logs#getactivelogs'
    map.post '/getlogs', 'logs#savelog'
    map.delete '/getlogs/:id', 'logs#discard'
