BaseModel = require("./models").BaseModel

###
  @file: mail_new.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Model which defines the new MAIL object (to send).
    
    In fact, it's just a container of data, to send easily to sendmail controller.

###
class exports.MailNew extends BaseModel
  
    url: "sendmail"
