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

    constructor: (options) ->

        attachments = options.model.get '_attachments'
        attachmentsarr = []
        for key, value of attachments
            value['fileName'] = key
            attachmentsarr.push value

        @collection = new Backbone.Collection attachmentsarr
        super

    initialize: ->
        super
        @listenTo @collection,
            'request' : @spin
            'sync'    : @spin

    itemViewOptions: ->
        mail: @model

    spin: ->
        @$el.spin "small"
