class exports.MenuView extends Backbone.View
  id: "menu"
  className: "mailboxes"
  el: 
    
  constructor: (@el, @collection) ->
    super()

  render: ->
    @collection.fetch()
    $("#mail_list_container").html("")
    @collection.each @addOne
    # $("#mail_list_container").html "lama lama"
    $("#mail_list_container")
