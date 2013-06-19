example ?= {}
example.converter ?= {}

example.converter.start = ->
  example.converter.controller
    views:
      conversionForm: calatrava.bridge.pages.pageNamed "conversionForm"
    changePage: calatrava.bridge.changePage
    repository: example.converter.repository calatrava.bridge.request

  calatrava.bridge.changePage "conversionForm"
