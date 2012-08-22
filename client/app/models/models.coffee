###

    Base class which contains methods common for all the models.
    Might get useful at some point, even though it's not visible yet...
 
###
class exports.BaseModel extends Backbone.Model
  
  debug : true

  isNew: () ->
    not @id?

  prerender: () ->
    console.log "Prerender" if @debug?
    for prop, val of @attributes
      @["_" + prop] = @[prop] (val)
      if @["render_" + prop]?
        console.log "rendering " + prop +  " -> __" + prop if @debug?
        @["_" + prop] = @["_render_" + prop] (val)
      else
        console.log "copying " + prop +  " -> __" + prop if @debug?
        @["__" + prop] = @attributes[prop]
    console.log @ if @debug?
    @
    

  render_from: (from) ->
    parsed = JSON.parse(from)
    out = ""
    for obj in parsed
      out += obj.name + " <" + obj.address + "> "
    out
    
  render_date: (date) ->
    parsed = new Date date
    parsed.toUTCString()