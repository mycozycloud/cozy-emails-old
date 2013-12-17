BaseView = require 'lib/base_view'

class exports.Modal extends BaseView
    id: 'confirm-delete-modal'
    template: require('templates/_mailbox/modal')
    className: 'modal hide fade in'
    attributes:
      'role': 'dialog'
      'aria-hidden': 'true'

    currentCallback: ->

    events: =>
      'click .yes-button' : => @currentCallback?()
      'hide': => @currentCallback = null

    showAndThen: (callback) =>
      @currentCallback = callback
      @$el.modal()