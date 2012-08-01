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
    @view_mails_list = new MailsList @.$("#mails_list_container"), @collection
    @view_mails_list_more = new MailsListMore @.$("#button_load_more_mails"), @collection
    @view_mails_list.render()
    @view_mails_list_more.render()
    @