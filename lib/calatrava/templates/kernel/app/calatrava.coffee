calatrava ?= {}
calatrava.bridge ?= {}

calatravaId = () ->
  str = ''
  _.times 32, () ->
    r = Math.floor(Math.random() * 16)
    str = str + r.toString(16)
  str.toUpperCase()

calatrava.inbound =
  dispatchEvent: (proxyId) ->
    extraArgs = _.map(_.toArray(arguments).slice(1), ((obj) -> obj.valueOf() if obj?))
    proxyPage = calatrava.bridge.pages.pageByProxyId(proxyId)
    proxyPage.dispatch.apply(proxyPage, extraArgs)

  fieldRead: (proxyId, getId, fieldValue) ->
    proxyPage = calatrava.bridge.pages.pageByProxyId(proxyId)
    proxyPage.fieldRead(getId, fieldValue)

  successfulResponse: (requestId, response) ->
    calatrava.bridge.requests.successfulResponse(requestId, response)

  failureResponse: (requestId, errorCode, response) ->
    calatrava.bridge.requests.failureResponse(requestId,errorCode, response)

  fireTimer: (timerId) ->
    calatrava.bridge.timers.fireTimer(timerId)

  invokePluginCallback: (handle, data) ->
    calatrava.bridge.plugins.invokeCallback(handle, data)

calatrava.bridge.changePage = (target) ->
  calatrava.bridge.runtime.changePage(target)
  target

calatrava.bridge.alert = (message) ->
  calatrava.bridge.log("WARN: calatrava.bridge.alert is deprecated. Please use calatrava.alert() instead.")
  calatrava.alert(message)

calatrava.bridge.openUrl = (url) ->
  calatrava.bridge.runtime.openUrl(url)

calatrava.bridge.log = (message) ->
  calatrava.bridge.runtime.log(message)

calatrava.bridge.request = (options) ->
  if options.contentType?
    options.customHeaders ||= {}
    options.customHeaders['Content-Type'] = options.contentType
  calatrava.bridge.requests.issue(
    options.url,
    options.method,
    options.body,
    options.success,
    options.failure,
    options.customHeaders
  )

calatrava.bridge.widgets = (() ->
  callbacks = {}

  display: (name, options, callback) ->
    # Runtime call to display the widget
    callbacks[name] = callback

  callback: (name) ->
    callbacks[name]
)()

calatrava.bridge.pageObject = (pageName) ->
  proxyId = calatravaId()
  handlerRegistry = {}
  outstandingGets = {}

  calatrava.bridge.runtime.registerProxyForPage(proxyId, pageName)

  bind: (event, handler) ->
    handlerRegistry[event] = handler
    calatrava.bridge.runtime.attachProxyEventHandler(proxyId, event)

  bindAll: (options) ->
    _.each options, (handler, event) => pageObject.bind event, handler

  dispatch: (event) ->
    args = _.toArray(arguments).slice(1)
    handlerRegistry[event]?.apply(this, args)

  get: (field, callback) ->
    getId = calatravaId()
    outstandingGets[getId] = callback
    calatrava.bridge.runtime.valueOfProxyField(proxyId, field, getId)

  fieldRead: (getId, fieldValue) ->
    outstandingGets[getId](fieldValue)
    delete outstandingGets[getId]

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

  render: (viewObject) -> calatrava.bridge.runtime.renderProxy(viewObject, proxyId)
  proxyId: proxyId

calatrava.bridge.pages = (()->
  pagesByName = {}
  pagesByProxyId = {}

  pageNamed: (pageName) ->
    if !pagesByName[pageName]?
      page = calatrava.bridge.pageObject(pageName)
      pagesByName[pageName] = page
      pagesByProxyId[page.proxyId] = page
    pagesByName[pageName]

  pageByProxyId: (proxyId) ->
    pagesByProxyId[proxyId]
)()

calatrava.bridge.requests = (() ->
  successHandlersById = {}
  failureHandlersById = {}

  clearHandlers = (requestId) ->
    delete successHandlersById[requestId]
    delete failureHandlersById[requestId]

  issue: (url, method, body, success, failure, customHeaders) ->
    requestId = calatravaId()
    bodyStr = body

    if bodyStr? && bodyStr.constructor != String
      bodyStr = JSON.stringify(body)

    successHandlersById[requestId] = success
    failureHandlersById[requestId] = failure

    calatrava.bridge.runtime.issueRequest
      requestId: requestId
      url: url
      method: method
      body: bodyStr
      headers: customHeaders
      success: success
      failure: failure

  successfulResponse: (requestId, response) ->
    successHandlersById[requestId](response)
    clearHandlers(requestId)

  failureResponse: (requestId, response) ->
    failureHandlersById[requestId](response)
    clearHandlers(requestId)
)()

calatrava.bridge.timers = (() ->
  callbacks= {}

  start: (timeout, callback) ->
    timerId = calatravaId()
    callbacks[timerId] = callback
    calatrava.bridge.runtime.startTimerWithTimeout(timerId, timeout)
    timerId

  fireTimer: (timerId) ->
    callbacks[timerId]() if callbacks[timerId]

  clearTimer: (timerId) ->
    delete callbacks[timerId]
)()

calatrava.bridge.plugins = (() ->
  registered = {}
  callbacks = {}

  call: (pluginName, method, argMessage) ->
    calatrava.bridge.runtime.callPlugin(pluginName, method, argMessage)

  register: (pluginName, callback) ->
    registered[pluginName] = callback

  run: (pluginName, method, argMessage) ->
    registered[pluginName](method, argMessage)

  rememberCallback: (callback) ->
    _.tap calatravaId(), (handle) ->
      callbacks[handle] = callback

  invokeCallback: (handle, data) ->
    callbacks[handle](data)
    delete callbacks[handle]
)()

calatrava.bridge.plugin = (name, impl) ->
  calatrava.bridge.plugins.register(name, impl)
