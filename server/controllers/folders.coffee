MailFolder = require '../models/mailfolder'

module.exports =

    getFolder:  (req, res, next, id) ->
        MailFolder.find id, (err, folder) =>
            if err
                next err
            else if not folder
                res.send error: 'not found', 404
            else
                req.folder = folder
                next()

    index: (req, res, next) ->
        MailFolder.all (err, folders) ->
            if err
                next err
            else
                res.send folders or []

    show: (req, res, next) ->
        res.send req.folder
