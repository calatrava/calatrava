tw ?= {}

tw =
  bridge:
    changePage: (page) ->
      page.show()

    alert: (msg) ->
      console.log("alerting: #{msg}")

    openUrl: (url) ->
      console.log("launching url: #{url}")

    timers:
      start: () ->
      clearTimer: () ->

    dialog:
      display: () ->

exports.tw = tw
