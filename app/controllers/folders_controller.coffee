# shared functionnality : find the folder via its ID
before ->
    MailFolder.find params.id, (err, folder) =>
        if err
            console.log err
            send 500
        else if not folder
            send 404
        else
            @folder = folder
            next()
, only: ['show']

# list folders
action 'index', ->
    MailFolder.all (err, folders) ->
        return send error: err, 500 if err
        send folders

# find folder with given id
action 'show', ->
    send @folder

