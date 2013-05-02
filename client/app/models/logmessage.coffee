BaseModel = require("./models").BaseModel

###
  @file: logmessage.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description:
    Model which represents a log message - displayed to user

###
class exports.LogMessage extends BaseModel

    urlRoot: "logs/"
    idAttribute: "id"
