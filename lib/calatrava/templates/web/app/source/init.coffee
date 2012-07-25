root = this
root.calatrava ?= {}
calatrava = root.calatrava

# Replace with your namespace
root.example ?= {}
example = root.example

# Hide all the sub-pages when first launching the app
$('body > .page').hide()

window.onpopstate = (event) ->
  if event.state
    tw.bridge.changePage event.state.page
