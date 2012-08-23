exports.routes = (map) ->
    map.get '/', 'templates#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
    map.get '/mailslist/:timestamp.:num', 'mails#getlist'
    map.get '/mailsnew/:timestamp', 'mails#getnewlist'
    
    map.put '/sendmail/:id', 'mailboxes#sendmail'
    map.post '/sendmail/:id', 'mailboxes#sendmail'

    map.get '/getattachments/:mail', 'mails#getattachmentslist'
    map.get '/getattachment/:attachment', 'mails#getattachment'