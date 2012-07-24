stubView ?= {}

stubView =
  create: (name) ->
    boundEvents: {}
    trigger: (event) ->
      @boundEvents[event]()

    bind: (event, handler) ->
      @boundEvents[event] = handler

    render: (viewObject) ->

    get: jasmine.createSpy('get')

    hideErrors: ()->

exports.stubView = stubView
