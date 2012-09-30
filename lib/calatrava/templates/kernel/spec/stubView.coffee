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
