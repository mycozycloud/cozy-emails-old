{Mail} = require "../models/mail"
{MailsList} = require "./mails_view"
{MailsMore} = require "./mails_more_view"

class exports.MailsColumnList extends Backbone.View
  id: "mailboxeslist"
  className: "mailboxes"

  constructor: (@el, @collection) ->
    super()

  render: ->
    $(@el).html require('./templates/_mail/mails')
    @view_mails_list = new MailsList @.$("#mails_list_container"), @collection
    @view_mails_list_more = new MailsMore @.$("#button_load_more_mails"), @collection
    @view_mails_list.render()
    @view_mails_list_more.render()
    @