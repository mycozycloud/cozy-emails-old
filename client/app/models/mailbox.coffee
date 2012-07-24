BaseModel = require("./models").BaseModel

# Defines a mailbox
class exports.Mailbox extends BaseModel

  defaults:
    'config' : 0
    'name' : "Mailbox"
    'createdAt' : "0"
    'SMTP_server' : "smtp.gmail.com"
    'SMTP_port' : "465"
    'SMTP_login' : "login"
    'SMTP_pass' : "pass"
    'SMTP_send_as' : "You"