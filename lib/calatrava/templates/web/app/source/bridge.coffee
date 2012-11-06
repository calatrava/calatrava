calatrava ?= {}
calatrava.bridge = calatrava.bridge ? {}
calatrava.bridge.web = calatrava.bridge.web ? {}

calatrava.bridge.environment = () ->
  sessionTimeout: 600
  serviceEndpoint: ""
  apiEndpoint: ""

calatrava.bridge.web.ajax = (options) ->
  loader = $("#loader")

  errorHandler = () ->
    loader.find('.load').hide()
    loader.find('.error').show()
    loader.find('.error a').bind 'click', hideLoader
    loader.show()

  setCustomHeaders = (xhr, headers) ->
    _.map(headers, (value, key) ->
      xhr.setRequestHeader(key, value)
    )

  showLoader = () ->
    loader.css({
      height: $(document.offset).height
      width: $(document.offset).width
      top: document.body.scrollTop
    })
    loader.find('.box').css({
      top: (($(document.offset).height / 2) - (loader.height() / 2) - 50)
    })
    loader.find('.error').hide()
    loader.find('.load').show()
    $(document.body).css overflow: 'hidden'
    loader.show()

  hideLoader = () ->
    $(document.body).css overflow: 'auto'
    loader.hide()

  goToTop = ->
    document.body.scrollTop = 0

  $.ajax
    url: options.url
    type: options.method
    data: options.body
    contentType: (() ->
      customHeaderTemp = {}
      for key of options.customHeaders
        if key is "Content-Type"
          contentTypeHeader = options.customHeaders[key]
        else
          customHeaderTemp[key] = options.customHeaders[key]

      options.customHeaders = customHeaderTemp
      contentTypeHeader;
    )()
    beforeSend: (xhr) ->
      if options.customHeaders
        setCustomHeaders(xhr, options.customHeaders)
      showLoader()
    success: (response) ->
      goToTop()
      options.success(response)
    error: () ->
      showLoader()
      options.failure()
    complete: hideLoader

calatrava.bridge.web.page = (pageName, proxyId) ->
  real = calatrava.pageView[pageName]()
  handlers = {}
  methods =
    bind: (event, callback) ->
      if event == 'pageOpened'
        handlers.pageOpened = callback
      else
        real.bind(event, callback)

    trigger: (event) ->
      handlers[event]() if handlers[event]?

    get: (field, getId) ->
      calatrava.inbound.fieldRead(proxyId, getId, String(real.get(field)))

  # Most functions just route through to the original
  _.each ['render', 'show', 'hide'], (method) ->
    methods[method] = () -> real[method].apply(real, arguments)

  methods

calatrava.bridge.runtime = (() ->

  pages = {}
  pagesNamed = {}
  currentPage = null
  plugins = {}

  registerProxyForPage: (proxyId, pageName) ->
    pages[proxyId] = calatrava.bridge.web.page(pageName, proxyId)
    pagesNamed[pageName] = pages[proxyId]

  changePage: (page, options = {}) ->
    pageObject = pagesNamed[page]
    if !options.back
      history.pushState({page: page}, "", "")
    currentPage.hide() if currentPage
    pageObject.show()
    currentPage = pageObject
    pageObject.trigger 'pageOpened'

  attachProxyEventHandler: (proxyId, event) ->
    pages[proxyId].bind event, () ->
      args = [proxyId, event].concat(_.toArray(arguments))
      calatrava.inbound.dispatchEvent.apply(calatrava.inbound, args)

  valueOfProxyField: (proxyId, field, getId) -> pages[proxyId].get(field, getId)
  renderProxy: (viewObject, proxyId) -> pages[proxyId].render(viewObject)
  issueRequest: calatrava.bridge.web.ajax
  openUrl: (url) -> window.open(url)
  log: (message) -> console.log(message)

  startTimerWithTimeout: (timerId, timeout) ->
    window.setTimeout((() -> calatrava.inbound.fireTimer(timerId)), timeout * 1000)

  registerPlugin: (pluginName, callback) ->
    plugins[pluginName] = callback

  callPlugin: (plugin, method, args) ->
    plugins[plugin](method, args)

  invokePluginCallback: (handle, data) ->
    calatrava.inbound.invokePluginCallback(handle, data)
)()
