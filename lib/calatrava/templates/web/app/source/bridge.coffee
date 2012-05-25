tw ?= {}
tw.bridge = tw.bridge ? {}

tw.bridge.environment = () ->
  sessionTimeout: 600
  serviceEndpoint: ""
  apiEndpoint: ""

tw.bridge.pageProxy = (name, real) ->
  handlers = {}
  methods =
    bind: (event, callback) ->
      if event == 'pageOpened'
        handlers.pageOpened = callback
      else
        real.bind(event, callback)

    trigger: (event) ->
      handlers[event]() if handlers[event]?

    get: (field) -> String(real.get(field))

  # Most functions just route through to the original
  _.each ['render', 'show', 'hide', 'showDialog'], (method) ->
    methods[method] = () -> real[method].apply(real, arguments)

  methods

class tw.bridge.pages
  pageObjects = {}

  pages.pageNamed = (pageName) ->
    pageObjects[pageName] = tw.bridge.pageProxy(pageName, realPageForName(pageName)) if !pageObjects[pageName]
    pageObjects[pageName]

tw.bridge.changePage = (page, options = {}) ->
  pageObject = tw.bridge.pages.pageNamed page
  if !options.back
    history.pushState({page: page}, "", "")
  tw.currentPage.hide() if tw.currentPage
  pageObject.show()
  tw.currentPage = pageObject
  pageObject.trigger 'pageOpened'
  page

tw.bridge.widgets = (() ->
  displayDateWidget = (options, callback) ->
    options["month"] = Number(options["month"])+1
    _.each ["year", "month", "day"], (val) -> $("#dummy_" + val).val(options[val]) if !$("#dummy_" + val).val()
    $("#dummy_date_picker").show()

    $("#dummy_date_button").unbind().bind 'click', () ->
      $("#dummy_date_picker").hide()
      callback $("#dummy_year").val(), $("#dummy_month").val() - 1, $("#dummy_day").val()

  displayAirportWidget = (callback) ->
    $("#dummy_airport_select_widget").show()

    $("#dummy_airport_set_button").unbind().bind 'click', () ->
      $("#dummy_airport_select_widget").hide()
      airportCode = $("#dummy_airport_code").val()
      airportMap = {ORD: "Chicago", ATL: "Atlanta", DEL: "Delhi", BOM: "Mumbai"}
      callback airportCode, airportMap[airportCode]


  display: (widget, options, callback) ->
    if widget == "date"
      displayDateWidget options.selectedDate, callback
    else if widget == "airport"
      displayAirportWidget callback
)()

tw.bridge.alert = (msg) -> alert(msg)

tw.bridge.openUrl = (url) ->
  window.open(url)

tw.bridge.trackEvent = (pageName, channel, eventName, variables, properties) ->
  describedKeyValuePairs = (pairs) -> _.map(pairs, (val, key) -> "#{key}: '#{val}'").join('; ')
  console.log "Omniture track event: page: '#{pageName}'; channel: '#{channel}'; events: '#{eventName}'"
  console.log "Omniture variables: #{describedKeyValuePairs(variables)}"
  console.log "Omniture properties: #{describedKeyValuePairs(properties)}"

tw.bridge.timers = (() ->
  start: (timeout, callback) ->
    window.setTimeout(callback, timeout * 1000)

  clearTimer: (timerId) ->
)()

tw.bridge.dialog = (() ->
  display: (dialogName) ->
    tw.currentPage.showDialog dialogName
)()

tw.bridge.request = (options) ->
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
