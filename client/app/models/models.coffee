###
    @file: models.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
        Base class which contains methods common for all the models.
        Might get useful at some point, even though it's not visible yet...
 
###
class exports.BaseModel extends Backbone.Model
    
    isNew: () ->
        not @id?

    prerender: () ->
        for prop, val of @attributes
            @["_" + prop] = @[prop] (val)
            if @["render_" + prop]?
                @["_" + prop] = @["_render_" + prop] (val)
            else
                @["__" + prop] = @attributes[prop]
        @
