calatrava.alert = (message) ->
  calatrava.bridge.plugins.call('alert', 'displayModal', {message: message})
