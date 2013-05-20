calatrava.alert = (message) ->
  calatrava.bridge.plugins.call 'alert', 'displayAlert',
    message: message

calatrava.confirm = (message, onOkExecute) ->
  okCallbackHandle = calatrava.bridge.plugins.rememberCallback (result) ->
    calatrava.bridge.plugins.deleteCallback(okCallbackHandle)
    onOkExecute(result)

  calatrava.bridge.plugins.call 'alert', 'displayConfirm',
    message: message
    okHandler: okCallbackHandle
