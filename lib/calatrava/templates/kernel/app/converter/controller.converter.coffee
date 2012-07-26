example.converter ?= {}

example.converter.controller = ({views, changePage, ajax}) ->

  currencies = ['USD','AUD','GBP']
  inCurrency = "USD"
  outCurrency = "AUD"

  currencyDropdownViewMessage = (selectedCurrency,unselectableCurrency) ->
    _.map( currencies, (c) ->
      {
        code: c,
        enabled: c != unselectableCurrency
        selected: c == selectedCurrency
      })

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

  views.conversionForm.bind 'convert', ->
    amount = views.conversionForm.get('in_amount')
    start = views.conversionForm.get('in_currency')
    end = views.conversionForm.get('out_currency')

  views.conversionForm.bind 'selectedInCurrency', (selectedCurrency) ->
    inCurrency = selectedCurrency
    renderOutCurrencyList()


  views.conversionForm.bind 'selectedOutCurrency', (selectedCurrency) ->
    outCurrency = selectedCurrency
    renderInCurrencyList()

  renderInCurrencyList()
  renderOutCurrencyList()
