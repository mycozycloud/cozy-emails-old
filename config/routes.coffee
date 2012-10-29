exports.routes = (map) ->
    map.get '/', 'templates#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
    map.get '/mailslist/:timestamp.:num/:id', 'mails#getlist'
    map.get '/mailsnew/:timestamp/:id', 'mails#getnewlist'
    
    map.put '/sendmail/:id', 'mailboxes#sendmail'
    map.post '/sendmail/:id', 'mailboxes#sendmail'
    
    map.get '/importmailbox/:id', 'mailboxes#import'
    map.get '/fetchmailbox/:id', 'mailboxes#fetch'
    map.get '/fetchmailboxandwait/:id', 'mailboxes#fetchandwait'

    map.get '/getattachments/:mail', 'mails#getattachmentslist'
    map.get '/getattachment/:attachment', 'mails#getattachment'
    
    map.get '/getlogs', 'logs#getactivelogs'
    map.delete '/getlogs/:id', 'logs#discard'