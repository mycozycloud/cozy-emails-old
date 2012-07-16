exports.routes = (map) ->
    map.get '/', 'templates#index'
    
    map.namespace 'api', (api) ->
        api.resources 'mailboxes'
        api.resources 'mails'
