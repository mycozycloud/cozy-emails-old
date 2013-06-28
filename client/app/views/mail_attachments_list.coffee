{MailAttachmentsListElement} = require "views/mail_attachments_list_element"
ViewCollection = require 'lib/view_collection'

###
    @file: mails_attachments_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        The list of attachments, created every time user displays a mail.
###

class exports.MailAttachmentsList extends ViewCollection

    itemView: MailAttachmentsListElement
    template: require 'templates/_mail/attachments'
    className: 'attachments-box'

    initialize: ->
        super
        @listenTo @collection,
            'request' : @spin
            'sync'    : @spin

    spin: ->
        @$el.spin "small"
