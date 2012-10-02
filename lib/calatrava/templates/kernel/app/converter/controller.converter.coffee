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

  convert = () ->
    views.conversionForm.get 'in_amount', (inAmount) ->
      outRate = currencyRate[outCurrency]
      inRate = currencyRate[inCurrency]
      views.conversionForm.render
        out_amount: (Math.round(inAmount * (outRate / inRate) * 100)) / 100

  views.conversionForm.bind 'convert', convert

  views.conversionForm.bind 'selectedInCurrency', ->
    views.conversionForm.get 'in_currency', (in_currency) ->
      inCurrency = in_currency
      views.conversionForm.render
        outCurrencies: currencyDropdownViewMessage outCurrency, inCurrency

  views.conversionForm.bind 'selectedOutCurrency', ->
    views.conversionForm.get 'out_currency', (out_currency) ->
      outCurrency = out_currency
      views.conversionForm.render
        inCurrencies: currencyDropdownViewMessage inCurrency, outCurrency

  views.conversionForm.render
    inCurrencies: currencyDropdownViewMessage inCurrency, outCurrency
    outCurrencies: currencyDropdownViewMessage outCurrency, inCurrency
    in_amount: 1
