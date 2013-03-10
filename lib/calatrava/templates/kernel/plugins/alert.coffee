calatrava.alert = (message) ->
  calatrava.bridge.plugins.call 'alert', 'displayAlert',
    message: message

calatrava.confirm = (message, onOkExecute) ->
  okCallbackHandle = calatrava.bridge.plugins.rememberCallback () ->
    calatrava.bridge.plugins.deleteCallback(okCallbackHandle)
    onOkExecute()

  calatrava.bridge.plugins.call 'alert', 'displayConfirm',
    message: message
    okHandler: okCallbackHandle
