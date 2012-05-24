tw ?= {}
tw.bridge = tw.bridge ? {}

generateRandomString = () ->
  str = ''
  for i in [0..32]
    r = Math.floor(Math.random() * 16)
    str = str + r.toString(16)
  return str.toUpperCase();

tw.bridge.environment = () ->
  serviceEndpoint: "http://localhost:4568"
  apiEndpoint: "http://localhost:4568"
  sessionTimeout: 10

tw.bridge.dispatchEvent = (page, event) ->
  tw.bridge.pages.pageNamed(page).dispatch(event)

class tw.bridge.Page
  constructor: (@pageName) ->
    @fieldValues = {}
    @handlerRegistry = {}
    @renderObjects = []

  bind: (event, handler) ->
    @handlerRegistry[event] = handler

  trigger: (event) ->
    @handlerRegistry[event]()

  dispatch: (event) ->
    args = _.toArray(arguments).slice(2)
    @handlerRegistry[event].apply(this, args)

  get: (field) ->
    @fieldValues[field]

  stubField: (field, value) ->
    @fieldValues[field] = value

  render: (viewObject) ->
    @renderObjects.push(viewObject)
    that = this
    _.map(viewObject, (value, key) ->
      that.stubField(key, value)
    )

  lastRender: () ->
    @renderObjects[@renderObjects.length - 1]

  allRenderObjects: () ->
    @renderObjects

tw.bridge.changePage = (target) ->
  tw.bridge.pages.setCurrent(target)
  tw.bridge.changedPage = target

tw.bridge.pages = (() ->
  pagesByName = {}
  current = ""

  pageNamed: (pageName) ->
    if (!pagesByName[pageName])
      pagesByName[pageName] = new tw.bridge.Page(pageName)
    pagesByName[pageName]

  current: () -> pagesByName[current]
  setCurrent: (newPage) -> current = newPage
)()

class tw.bridge.Widget
  constructor: (@name, @options, @callback) ->

  getCallback: ->
    @callback

  getOptions: ->
    @options

tw.bridge.widgets = (()->
  widgets = {}
  display: (name, options, callback) ->
    widgets[name] = new tw.bridge.Widget(name, options, callback)

  widget: (name) ->
    widgets[name]
)()

tw.bridge.timers = (() ->
  timers = {}
  start: (timeout, callback) ->
    timers["searchResultsExpired"] = callback

  clearTimer: () ->

  triggerTimer: (name) ->
    timers[name]()
)()

tw.bridge.dialog = (() ->
  display: (name) ->
)()

tw.bridge.request = (reqOptions) ->
  # mock this for kernel features
  response = tw.bridge.requests.issue reqOptions
  if response.status == 'successful'
    reqOptions.success(response.body)
  else
    reqOptions.failure(response.body)

tw.bridge.requests = (() ->
  storedRequests = []

  stubRequest: (options) ->
    storedRequests.push(options)

  issue: (options) ->
    _.tap _.chain(storedRequests).filter((sr) -> sr.url.test(options.url)).last().value().response, (v) ->
)()

tw.bridge.alert = (message) ->

tw.bridge.trackEvent = () ->
