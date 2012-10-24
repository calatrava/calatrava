calatrava ?= {}
calatrava.bridge = calatrava.bridge ? {}

calatrava.bridge.runtime = (() ->
  pages = {}

  changePage: (target) -> pageRegistry.changePage(target)

  registerProxyForPage: (proxyId, pageName) ->
    pages[proxyId] = pageName
    pageRegistry.registerProxyForPage(pageName, proxyId)

  log: (message) -> androidRuntime.log(message)
  attachProxyEventHandler: (proxyId, event) ->
  startTimerWithTimeout: (timerId, timeout) -> pageRegistry.startTimer(timeout, timerId)
  openUrl: (url) -> pageRegistry.openUrl(url)

  valueOfProxyField: (proxyId, field, getId) ->
    value = String(pageRegistry.getValueForField(pages[proxyId], field))
    calatrava.inbound.fieldRead(proxyId, getId, value)

  renderProxy: (viewObject, proxyId) ->
    pageRegistry.renderPage(pages[proxyId], JSON.stringify(viewObject))

  issueRequest: (options) ->
    ajaxRequestManagerRegistry.makeRequest(options.requestId,
      options.url,
      options.method,
      options.body,
      options.headers)

  callPlugin: (plugin, method, args) ->
    pluginRegistry.call(plugin, method, JSON.stringify(args))
)()
