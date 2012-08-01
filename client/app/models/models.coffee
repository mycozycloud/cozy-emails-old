###

    Base class which contains methods common for all the models.
    Might get useful at some point, even though it's not visible yet...
 
###
class exports.BaseModel extends Backbone.Model

  isNew: () ->
    not @id?