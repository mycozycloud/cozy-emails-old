{Mail} = require "../models/mail"

{MailsSentList} = require "../views/mailssent_list"
{MailsListMore} = require "../views/mails_list_more"

###
  @file: mailssent_column.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The view of the central column - the one which holds the list of mail.
  
###

class exports.MailsSentColumn extends Backbone.View
  id: "mailslist"
  className: "mails"

  constructor: (@el, @collection) ->
    super()

  render: ->
    $(@el).html require('./templates/_mail/mails')
    # the actual list of mails
    @viewMailsSentList = new MailsSentList @.$("#mails_list_container"), @collection
    # the button to load older mail
    @viewMailsListMore = new MailsListMore @.$("#button_load_more_mails"), @collection

    @viewMailsSentList.render()
    @viewMailsListMore.render()
    @