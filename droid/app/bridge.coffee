tw ?= {}
tw.bridge = tw.bridge ? {}

generateRandomString = () ->
  str = ''
  for i in [1...32]
    r = Math.floor(Math.random() * 16)
    str = str + r.toString(16)
  str.toUpperCase()

tw.bridge.dispatchEvent = (page, event) ->
  extraArgs = _.toArray(arguments).slice(1);
  tw.bridge.pages.pageNamed(page).dispatch.apply(tw.bridge.pages.pageNamed(page), extraArgs)

class tw.bridge.Page
  constructor: (@pageName) ->
    @handlerRegistry = {}

  bind: (event, handler) ->
    @handlerRegistry[event] = handler
    # Register that an event handler has been installed?

  dispatch: (event) ->
    args = _.toArray(arguments).slice(1)
    if @handlerRegistry[event]?
      @handlerRegistry[event].apply(this, args)

  get: (field) ->
    String(pageRegistry.getValueForField(@pageName, field))

  render: (viewObject) ->
    viewObject = JSON.stringify(viewObject)
    pageRegistry.renderPage(@pageName, viewObject)


tw.bridge.changePage = (target) ->
  pageRegistry.changePage(target)
  target

tw.bridge.pages = (() ->
  pagesByName = {}

  pageNamed: (pageName) ->
    if (!pagesByName[pageName])
      pagesByName[pageName] = new tw.bridge.Page(pageName)
    pagesByName[pageName]
)()

tw.bridge.widgets = (()->
  callbacks = {}
  display: (name, options, callback) ->
    pageRegistry.displayWidget(name, JSON.stringify(options))
    callbacks[name] = callback

  invokeCallback: (name) ->
    args = _.toArray(arguments).slice(1)
    callbacks[name].apply(this, args)
)()

tw.bridge.dialog = (()->
  display : (name) ->
    pageRegistry.displayDialog(name)
)()

tw.bridge.request = (reqOptions) ->
  tw.bridge.requests.issue reqOptions

tw.bridge.requests = (() ->
  successHandlers = {}
  failureHandlers = {}

  issue: (options) ->
    requestId = generateRandomString()
    if options.body
      bodyStr = options.body
    else
      bodyStr = ""
    if (bodyStr.constructor != String)
      bodyStr = JSON.stringify(body)

    if options.customHeaders
      headers = JSON.stringify(options.customHeaders)
    else
      headers = ""

    successHandlers[requestId] = options.success
    failureHandlers[requestId] = options.failure
    ajaxRequestManagerRegistry.makeRequest(requestId,
      options.url,
      options.method,
      bodyStr,
      headers)

  successfulResponse: (reqId, response) ->
    successHandlers[reqId](response)
    @clearHandlers(reqId)

  failureResponse: (reqId, errorCode, response) ->
    failureHandlers[reqId](errorCode, response)
    @clearHandlers(reqId)

  clearHandlers: (reqId) ->
    successHandlers[reqId] = null
    failureHandlers[reqId] = null
)()

tw.bridge.alert = (message) ->
  pageRegistry.alert(message)

tw.bridge.openUrl = (url) ->
  pageRegistry.openUrl(url)

tw.bridge.trackEvent = (pageName, channel, eventName, variables, properties) ->
  pageRegistry.track(pageName, channel, eventName, variables, properties)

tw.bridge.timers = (() ->
  callbacks = {}

  start: (timeout, callback) ->
    timerId = generateRandomString()
    callbacks[timerId] = callback
    pageRegistry.startTimer(timeout, timerId)
    timerId

  fireTimer: (timerId) ->
    callbacks[timerId]() if callbacks[timerId]

  clearTimer: (timerId) ->
    delete callbacks[timerId]
)()
