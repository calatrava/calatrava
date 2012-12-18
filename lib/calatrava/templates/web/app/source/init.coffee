root = this
root.calatrava ?= {}
calatrava = root.calatrava

# Hide all the sub-pages when first launching the app
$(document.ready) ->
  $('body > .container > .page').hide()

window.onpopstate = (event) ->
  if event.state
    tw.bridge.changePage event.state.page
