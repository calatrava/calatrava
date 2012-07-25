calatrava.shell ?= {}

calatrava.shell.pageHelper = ($page) ->

  handlers = {}

  handler: (name, callback) ->
    handlers[name] = callback

  trigger: (name) -> handlers[name]()

  reset: ->
    $("#overlay").remove()

  initialize: ->
    $page.off('click', 'a[data-href]').on 'click', 'a[data-href]', ()->
      handlers['static_link'] $(this).data 'href'
