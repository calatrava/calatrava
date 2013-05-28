calatrava ?= {}
calatrava.bridge = calatrava.bridge ? {}

generateRandomString = () ->
  str = ''
  for i in [0..32]
    r = Math.floor(Math.random() * 16)
    str = str + r.toString(16)
  return str.toUpperCase();

calatrava.bridge.dispatchEvent = (page, event) ->
  calatrava.bridge.pages.pageNamed(page).dispatch(event)

class calatrava.bridge.Page
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

calatrava.bridge.changePage = (target) ->
  calatrava.bridge.pages.setCurrent(target)
  calatrava.bridge.changedPage = target

calatrava.bridge.pages = (() ->
  pagesByName = {}
  current = ""

  pageNamed: (pageName) ->
    if (!pagesByName[pageName])
      pagesByName[pageName] = new calatrava.bridge.Page(pageName)
    pagesByName[pageName]

  current: () -> pagesByName[current]
  setCurrent: (newPage) -> current = newPage
)()

class calatrava.bridge.Widget
  constructor: (@name, @options, @callback) ->

  getCallback: ->
    @callback

  getOptions: ->
    @options

calatrava.bridge.widgets = (()->
  widgets = {}
  display: (name, options, callback) ->
    widgets[name] = new calatrava.bridge.Widget(name, options, callback)

  widget: (name) ->
    widgets[name]
)()

calatrava.bridge.timers = (() ->
  timers = {}
  start: (timeout, callback) ->
    timers["searchResultsExpired"] = callback

  clearTimer: () ->

  triggerTimer: (name) ->
    timers[name]()
)()

calatrava.bridge.dialog = (() ->
  display: (name) ->
)()

calatrava.bridge.request = (reqOptions) ->
  # mock this for kernel features
  response = calatrava.bridge.requests.issue reqOptions
  if response.status == 'successful'
    reqOptions.success(response.body)
  else
    reqOptions.failure(response.body)

calatrava.bridge.requests = (() ->
  storedRequests = []

  stubRequest: (options) ->
    storedRequests.push(options)

  issue: (options) ->
    _.tap _.chain(storedRequests).filter((sr) -> sr.url.test(options.url)).last().value().response, (v) ->
)()

calatrava.bridge.alert = (message) ->

calatrava.bridge.trackEvent = () ->
