example ?= {}
example.converter ?= {}

example.converter.repository = (ajax) ->
  exchangeRate: (options) ->
    ajax
      url: "#{example.converter.apiEndpoint}/currency?from=#{options.from}&to=#{options.to}"
      method: "GET"
      success: (response) ->
        options.ifSucceeded JSON.parse(response).rate
      failure: options.elseFailed