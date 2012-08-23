{Mail} = require "../models/mail"

{MailsList} = require "../views/mails_list"
{MailsListMore} = require "../views/mails_list_more"

###

  The view of the central column - the one which holds the list of mail.
  
###
class exports.MailsColumn extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"

  constructor: (@el, @collection) ->
    super()

  render: ->
    $(@el).html require('./templates/_mail/mails')
    @viewMailsList = new MailsList @.$("#mails_list_container"), @collection
    @viewMailsListMore = new MailsListMore @.$("#button_load_more_mails"), @collection
    @viewMailsList.render()
    @viewMailsListMore.render()
    @