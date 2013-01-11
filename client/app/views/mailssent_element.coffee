{MailSent} = require "../models/mail_sent"
{MailsAttachmentsList} = require "../views/mails_attachments_list"

###
  @file: mailssent_element.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    The mail view. Displays all data & options.
    Also, handles buttons.

###

class exports.MailsSentElement extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    @collection.on "change_active_mail", @render, @
    
  render: ->
    
    $(@el).html ""
    
    if @collection.activeMail?
      
      template = require('./templates/_mailsent/mailsent_big')
      
      $(@el).html template("model" : @collection.activeMail)
      
      if @collection.activeMail.hasHtml()
        
        # this timeout is a walkaround the firefox empty iframe onLoad issue.
        setTimeout () =>
          $("#mail_content_html").contents().find("html").html @collection.activeMail.html()
          # frames["mail_content_html"].document.documentElement.innerHTML = @collection.activeMail.html()
          
          # add some basic styling and targeting to the internal document
          $("#mail_content_html").contents().find("head").append '<link rel="stylesheet" href="css/reset_bootstrap.css">'
          $("#mail_content_html").contents().find("head").append '<base target="_blank">'
        
          # adjust the height of the iframe
          $("#mail_content_html").height $("#mail_content_html").contents().find("html").height()
          
          if $("#mail_content_html").contents().find("html").height() > 600
            $("#additional_bar").show()
          
        , 50
        
        # this timeout is a walkaround for content, which takes a while to load
        setTimeout () =>
          # adjust the height of the iframe
          $("#mail_content_html").height $("#mail_content_html").contents().find("html").height()
          
        , 1000
        
      if @collection.activeMail.get "hasAttachments"
        window.app.viewAttachments = new MailsAttachmentsList $("#attachments_list"), @collection.activeMail
    @