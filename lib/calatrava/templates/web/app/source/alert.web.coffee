calatrava.web ?= {}

calatrava.web.alert = (method, {message}) ->
  if method != 'runModal' || !message?
    console.log("Unable to display alert.")

  window.alert(message)

calatrava.bridge.runtime.registerPlugin 'alert', calatrava.web.alert
