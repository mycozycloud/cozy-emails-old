{Mailbox} = require "../models/mailbox"


class exports.MailboxCollection extends Backbone.Collection
    
  model: Mailbox
  url: 'mailboxes/'
  
  initialize: ->
    @fetch
    # dev data - useless
    # @add [
    #   "name": "miko", server: "s1"
    # ,
    #   "name": "miko2", server: "s2"
    # ]
  
  
  removeOne: (mailbox, view) ->
    mailbox.destroy
      success: ->
        view.remove()
      error: ->
        alert "error"
    view.remove()