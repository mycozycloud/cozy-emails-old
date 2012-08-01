BaseModel = require("./models").BaseModel

# Defines a mailbox
class exports.Config extends BaseModel

  defaults:
    'active_mailboxes' : {}
    'active_mail' : ""