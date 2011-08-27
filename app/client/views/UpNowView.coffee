View = Backbone.View.extend
  initialize: ->
    SS.events.on 'performance:init', @onPerformanceInit   
    SS.events.on 'performance:cancel', @onPerformanceCancel
    SS.events.on 'performance:perform', @onPerformancePerform
    SS.events.on 'performance:perform:end', @onPerformanceEnd

  events:
    "click #could-be": "onCouldBeClick"

  onCouldBeClick: (event) ->
    $(document).trigger 'joinQueueViewOpen'

  onPerformanceInit: (performance) ->
    $("#performer-name").text(performance.name)
    $("#performer-description").text(performance.desc)
    
    showInfo()
    hideEmpty()
    
  onPerformanceCancel: (performance) ->
    hideInfo()
    showEmpty()
      
  onPerformanceEnd: (performance) ->
    hideInfo()
    showEmpty()

$(document).ready ->    
  view = new View
    el: $("#performer")
    
hideInfo = ->
  $("#performer-info").hide 'fast'
  
showInfo = ->
  $("#performer-info").show 'fast'

hideEmpty = ->
  $("#nobody-on-stage").hide('fast')
  
showEmpty = ->
  $("#nobody-on-stage").show('fast')