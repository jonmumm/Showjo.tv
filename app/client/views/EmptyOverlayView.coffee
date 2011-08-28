View = Backbone.View.extend
  initialize: ->
    SS.events.on 'performance:stage', @onPerformanceStage
    SS.events.on 'performance:cancel', @onPerformanceCancel
    SS.events.on 'performance:perform:end', @onPerformanceEnd

  onPerformanceStage: (performance) ->
    hideOverlay()

  onPerformanceCancel: (performance) ->
    showOverlay()

  onPerformanceEnd: (performance) ->
    showOverlay()

$(document).ready ->
  view = new View
    el: $("#empty-overlay")

hideOverlay = ->
  $("#empty-overlay").hide()

showOverlay = ->
  $("#empty-overlay").show()
