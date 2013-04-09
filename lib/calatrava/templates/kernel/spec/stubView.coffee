stubView = stubView or {}

stubView =
  create: (name)->
    lastMessage = null

    boundEvents: {}
    fieldValues: {}
    trigger: (event, args...)->
      @boundEvents[event](args...)

    bind: (event, handler)->
      @boundEvents[event] = handler

    render: (viewMessage)->
      lastMessage = viewMessage

    lastMessage: ()-> lastMessage

    fieldContains: (name, value)-> @fieldValues[name] = value
    get: (name, callback)->
      callback(@fieldValues[name])

    getMany: (fields, callback)->
      results = {}
      getManyPrime = (remaining)=>
        if (remaining.length > 0)
          field = _.first(remaining)
          @get field, (fieldValue)->
            results[field] = fieldValue
            getManyPrime(_.rest(remaining))
        else
          callback(results)
      getManyPrime(fields)


    hideErrors: ()->

exports.stubView = stubView
