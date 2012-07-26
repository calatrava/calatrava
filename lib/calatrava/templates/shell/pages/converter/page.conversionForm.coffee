calatrava.pageView ?= {}

calatrava.pageView.conversionForm = ->

  #TODO: refactor out
  $page = $('#conversionForm')
  $p = (sel)-> $(sel,$page)

  eventHandlers = {}

  trigger = (event, args...) ->
    eventHandlers[event](args...)

  renderCurrencyDropdown = ($select, currencies)->
    $select.empty().html ich.currencyDropdownTmpl
      currencies: currencies

  renderSection = (key,data) ->
    switch key
      when 'inCurrencies' then renderCurrencyDropdown( $p('.in_currency'), data )
      when 'outCurrencies' then renderCurrencyDropdown( $p('.out_currency'), data )
      else console.warn( "unrecognized render section #{key}" )


  $p(".out_currency").on 'change', ->
    selectedCurrencyCode = $(this).val()
    trigger("selectedOutCurrency", selectedCurrencyCode)
  $p(".in_currency").on 'change', ->
    selectedCurrencyCode = $(this).val()
    trigger("selectedInCurrency", selectedCurrencyCode)

  bind: (event, handler) ->
    eventHandlers[event] = handler

  render: (message) ->
    console.log('rendering...', message)
    renderSection(section,data) for own section,data of message

  get: (field) -> console.log( 'getting...', field )
  
  show: -> console.log( 'showing...' )
  hide: -> console.log( 'hiding...' )
