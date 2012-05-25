tw ?= {}

tw.batSignal = () ->
  _batSignal = () ->
    if(!_iframe)
      _iframe = document.createElement('iframe')
      _iframe.setAttribute("id", "callback_iframe")
      _iframe.setAttribute("style", "display:none;")
      _iframe.setAttribute("height","0px")
      _iframe.setAttribute("width","0px")
      _iframe.setAttribute("frameborder","0")
      document.documentElement.appendChild(_iframe)
    return _iframe

tw.batSignalFor = (event) ->
  (args...) ->
    argStr = _.chain(args)
      .filter((v) -> v?)
      .reduce(((m, v) -> m + "&" + v), "")
      .value()
    window.batSignal().setAttribute('src', 'js-call:' + event + argStr)
