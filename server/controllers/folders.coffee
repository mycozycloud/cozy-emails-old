module.exports =

    getFolder:  (req, res, next, id) ->
        MailFolder.find req.params.id, (err, folder) =>
            if err
                next err
            else if not folder
                send error: 'not found', 404
            else
                req.folder = folder
                next()

    index: (req, res, next) ->
        MailFolder.all (err, folders) ->
            if err
                next err
            else
                send folders or []

    show: (req, res, next) ->
        send req.folder
