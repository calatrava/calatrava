example ?= {}
example.converter ?= {}

example.converter.start = ->
  example.converter.controller
    views:
      conversionForm: tw.bridge.pages.pageNamed "conversionForm"
    changePage: tw.bridge.changePage
    ajax: tw.bridge.request

  tw.bridge.changePage "conversionForm"
