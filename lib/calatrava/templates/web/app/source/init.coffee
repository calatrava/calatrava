example ?= {}
example.converter ?= {}
calatrava ?= {}

#cross-domain calls would fail for web. Using ProxyPass in httpd.conf instead.
example.converter.apiEndpoint = ""

# Hide all the sub-pages when first launching the app
$(document).ready ->
  $('body > .container > .page').hide()

window.onpopstate = (event) ->
  if event.state
    calatrava.bridge.changePage event.state.page
