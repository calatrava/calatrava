stubView ?= {}

stubView =
  create: (name) ->
    lastMessage = null

    boundEvents: {}
    fieldValues: {}
    trigger: (event, args...) ->
      @boundEvents[event](args...)

    after: (event, handler) ->
      priorHandler = @boundEvents[event]
      if priorHandler?
        @boundEvents[event] = (args...) ->
          priorHandler(args...)
          handler(args...)
      else
        @bind(event, handler)

    bind: (event, handler) ->
      @boundEvents[event] = handler

    render: (viewMessage) ->
      lastMessage = viewMessage

    lastMessage: () -> lastMessage

    fieldContains: (name, value) -> @fieldValues[name] = value
    get: (name, callback) ->
      callback(@fieldValues[name])

    getMany: (fields, callback) ->
      results = {}
      getManyPrime = (remaining) =>
        if (remaining.length > 0)
          field = _.first(remaining)
          @get field, (fieldValue) ->
            results[field] = fieldValue
            getManyPrime(_.rest(remaining))
        else
          callback(results)
      getManyPrime(fields)


    hideErrors: ()->

exports.stubView = stubView
