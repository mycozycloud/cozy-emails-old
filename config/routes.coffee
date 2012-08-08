exports.routes = (map) ->
    map.get '/', 'templates#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
    map.get '/mailslist/:timestamp.:num', 'mails#getlist'
    map.get '/mailsnew/:timestamp', 'mails#getnewlist'
