load 'application'

# before ->
#     Mailbox.find req.params.id, (err, box) =>
#         if err or not box
#             redirect path_to.mailboxes
#         else
#             @box = box
#             next()
# , only: ['índex', 'show', 'edit', 'update', 'destroy']

# GET /mailboxes
action 'index', ->
    Mailbox.all (err, box) ->
        send JSON.stringify(box)

# GET /mailboxes/:id
action 'show', ->
    send @box.toJSON()

# PUT /mailboxes/:id
action 'update', ->
    ['title', 'content'].forEach (field) =>
        @box[field] = req.body[field] if req.body[field]?

    @box.save (err) =>
        if not err
            flash 'info', 'Post updated'
        else
            flash 'error', 'Post can not be updated'

# DELETE /mailboxes/:id
action 'destroy', ->
    @box.remove (error) ->
        if error
            flash 'error', 'Can not destroy post'
        else
            flash 'info', 'Post successfully removed'