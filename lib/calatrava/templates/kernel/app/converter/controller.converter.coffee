example ?= {}
example.converter ?= {}

example.converter.controller = ({views, changePage, ajax}) ->
  currencies = ['USD', 'AUD', 'GBP', 'INR']
  currencyRate =
    USD: 1
    AUD: 0.96
    GBP: 0.62
    INR: 55

  inCurrency = "USD"
  outCurrency = "AUD"

  currencyDropdownViewMessage = (selectedCurrency, unselectableCurrency) ->
    _.map currencies, (c) ->
      code: c,
      enabled: c != unselectableCurrency
      selected: c == selectedCurrency

  renderCurrencyList = ({listName, disabled, selected}) ->
    viewMessage = {}
    viewMessage[listName] = currencyDropdownViewMessage(selected, disabled)
    views.conversionForm.render(viewMessage)

  renderOutCurrencyList = ()->
    renderCurrencyList
      listName: 'outCurrencies'
      disabled: inCurrency
      selected: outCurrency

  renderInCurrencyList = ()->
    renderCurrencyList
      listName: 'inCurrencies'
      disabled: outCurrency
      selected: inCurrency

  convert = () ->
    inAmount = views.conversionForm.get 'in_amount'
    outRate =  currencyRate[views.conversionForm.get 'out_currency']
    inRate = currencyRate[views.conversionForm.get 'in_currency']

    outAmount = (Math.round(inAmount * (outRate / inRate) * 100)) / 100
    views.conversionForm.render
      out_amount: outAmount

  views.conversionForm.bind 'convert', convert

  views.conversionForm.bind 'selectedInCurrency', ->
    inCurrency = views.conversionForm.get 'in_currency'
    renderOutCurrencyList()
    convert()

  views.conversionForm.bind 'selectedOutCurrency', ->
    outCurrency = views.conversionForm.get 'out_currency'
    renderInCurrencyList()
    convert()

  renderInCurrencyList()
  renderOutCurrencyList()
  views.conversionForm.render
    in_amount: 1
  convert()
