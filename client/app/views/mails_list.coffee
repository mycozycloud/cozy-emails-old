ViewCollection     = require 'lib/view_collection'
FolderMenu         = require 'views/folders_menu'

###
    @file: mails_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        View to generate the list of mails - the second column from the left.
        Uses MailsListElement to generate each mail's view
###

class exports.MailsList extends ViewCollection
    id: "mails_list"
    itemView: require("views/mails_list_element").MailsListElement
    template: require("templates/_mail/list")

    events:
        "click #add_more_mails"  : 'loadOlderMails'
        'click #markallread-btn' : 'markAllRead'

    initialize: ->
        super
        @listenTo window.app.mailboxes, 'change:color', @updateColors
        @listenTo window.app.mailboxes, 'add', @updateColors

        @foldermenu = new FolderMenu(collection: app.folders)
        @foldermenu.render()

    itemViewOptions: -> folderId: @collection.folderId

    checkIfEmpty: ->
        super
        empty = _.size(@views) is 0
        @noMailMsg?.toggle empty
        @$('#markallread-btn').toggle not empty
        @$('#add_more_mails').toggle not empty
        $('#refresh-btn').toggle not empty
        $('#refresh-btn').unbind 'click'
        $('#refresh-btn').click @refresh

    afterRender: ->
        @noMailMsg  = @$('#no-mails-message')
        @loadmoreBtn = @$ '#add_more_mails'
        @container   = @$ '#mails_list_container'

        @$('#topbar').append @foldermenu.$el
        @activate @activated if @activated
        @$el.niceScroll()
        super

    remove: ->
        @$el.getNiceScroll().remove()
        super

    appendView: (view) ->
        return unless @container
        dateValueOf = view.model.get 'dateValueOf'
        if dateValueOf < @collection.timestampNew
            # update timestamp for the list of messages
            if dateValueOf < @collection.timestampOld
                @collection.timestampOld = dateValueOf
                @collection.lastIdOld = view.model.id

            # add its view at the bottom of the list
            @container.append view.$el
        else
            # update timestamp for new messages
            if dateValueOf >= @collection.timestampNew
                @collection.timestampNew = dateValueOf
                @collection.lastIdNew = view.model.id

            # add its view on top of the list
            @container.prepend view.$el

    refresh: =>
        btn = $ '#refresh-btn'
        oldbtnVal = btn.html()
        btn.html '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
        btn.spin('small').addClass 'disabled'
        promise = $.ajax 'mails/fetch/new'

        promise.error (jqXHR, error) =>
            btn.text('Connection Error').addClass 'error'
            alert error

        promise.success (models) =>
            console.log "TODO: import new mails in the view"
            setTimeout @refresh, 600 * 1000

        promise.always ->
            btn.spin()
            btn.removeClass 'disabled'
            btn.html oldbtnVal

    markAllRead: -> @collection.each (model) ->
        unless model.isRead()
            model.markRead()
            model.save()

    # when user clicks on "more mails" button
    loadOlderMails: () ->

        # if not disabled
        return null if @loadmoreBtn.hasClass 'disabled'

        oldlength = @collection.length
        @loadmoreBtn.addClass("disabled").text "Loading..."

        promise = @collection.fetchOlder()
        promise.always =>
            @loadmoreBtn.removeClass('disabled').text "more messages"

        # hide button if it was useless
        promise.done => @loadmoreBtn.hide() if @collection.length is oldlength

    updateColors: () ->
        view.render() for id, view of @views

    activate: (id) ->
        @activated = id
        for cid, view of @views
            if view.model.id is id then view.$el.addClass 'active'
            else view.$el.removeClass 'active'
