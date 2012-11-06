calatrava.web ?= {}

calatrava.web.alert = (method, {message, okHandler}) ->
  if !message?
    console.log("Unable to display alert.")

  if method == 'displayAlert'
    window.alert(message)
  else if method == 'displayConfirm'
    userPressedOk = window.confirm(message)
    calatrava.bridge.runtime.invokePluginCallback(okHandler, userPressedOk)

calatrava.bridge.runtime.registerPlugin 'alert', calatrava.web.alert
