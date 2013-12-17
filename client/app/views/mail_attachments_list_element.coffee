###
    @file: mails_attachments_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Renders clickable attachments link.
###

BaseView = require 'lib/base_view'

class exports.MailAttachmentsListElement extends BaseView

    id: 'attachments_list'
    template: require 'templates/_attachment/attachment_element'
    getRenderData: ->
        attachment: @model,
        href: "mails/" + @options.mail.get("id") +
              "/attachments/" + @model.get("fileName")