exports.routes = (map) ->
    map.get '/', 'templates#index'
      
    map.resources 'mailboxes'
    map.resources 'mails'
