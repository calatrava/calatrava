calatrava.pageView ?= {}

calatrava.pageView.conversionForm = ->

  #TODO: refactor out
  $page = $('#conversionForm')
  $p = (sel)-> $(sel, $page)

  renderCurrencyDropdown = ($select, currencies)->
    $select.empty().html ich.currencyDropdownTmpl
      currencies: currencies

  renderSection = (key, data) ->
    switch key
      when 'inCurrencies' then renderCurrencyDropdown($p('#in_currency'), data)
      when 'outCurrencies' then renderCurrencyDropdown($p('#out_currency'), data)
      else $p("#" + key).val(data)

  bind: (event, handler) ->
    console.log "event: #{event}"
    switch event
      when 'selectedInCurrency' then $p("#in_currency").off('change').on 'change', handler
      when 'selectedOutCurrency' then $p("#out_currency").off('change').on 'change', handler
      else
        $p("#" + event).off('click').on 'click', handler

  render: (message) ->
    console.log('rendering...', message)
    renderSection(section, data) for own section,data of message

  get: (field) ->
    console.log('getting...', field)
    $page.find("#" + field).val()

  show: ->
    console.log('showing...')
    $page.show()

  hide: ->
    console.log('hiding...')
    $page.hide()
