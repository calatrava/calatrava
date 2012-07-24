example.converter ?= {}

example.converter.controller = ({views, changePage, ajax}) ->

  views.conversionForm.bind 'convert', ->
    amount = views.conversionForm.get('amount')
    start = views.conversionForm.get('start_currency')
    end = views.conversionForm.get('end_currency')
