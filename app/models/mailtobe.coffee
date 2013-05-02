module.exports = (compound, MailToBe) ->

    MailToBe.fromMailbox = (mailbox, callback) ->
        params =
            startkey: [mailbox.id + "0"]
            endkey: [mailbox.id]
            descending: true
        
        MailToBe.request "byMailbox", params, callback
