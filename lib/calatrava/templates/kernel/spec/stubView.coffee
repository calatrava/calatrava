stubView ?= {}

stubView =
  create: (name) ->
    boundEvents: {}
    fieldValues: {}
    trigger: (event) ->
      @boundEvents[event]()

    bind: (event, handler) ->
      @boundEvents[event] = handler

    render: jasmine.createSpy("#{name} render")

    fieldContains: (name, value) -> @fieldValues[name] = value
    get: (name) -> @fieldValues[name]

    hideErrors: ()->

exports.stubView = stubView
