View = Backbone.View.extend
  initialize: ->
    SS.events.on 'performance:stage', @onPerformanceStage    
    SS.events.on 'performance:cancel', @onPerformanceCancel
    SS.events.on 'performance:perform', @onPerformancePerform
    SS.events.on 'performance:perform:end', @onPerformanceEnd
    
  onPerformanceStage: (performance) ->
    if not showjo.opentok.connected
      alert 'Problem connecting to video stream'
      return
    
    appendPublisher()
  
    if performance.user_id is showjo.user._id
      showjo.opentok.addEventListener "streamCreated", (event) ->
        for stream in event.streams
          do (stream) -> 
            if stream.connection.connectionId is showjo.opentok.connection.connectionId
              SS.server.performance.publish stream, (response) ->
                # Some UI notification

      # Start publishing  
      showjo.opentok.publisher = showjo.opentok.publish "publisher-container",
        width: $("#publisher-wrapper").width()
        height: $("#publisher-wrapper").height()

      $("##{showjo.opentok.publisher.id}").addClass "publisher-object"

  onPerformancePerform: (performance) ->
    if performance.user_id isnt showjo.user._id
      subscriber = showjo.opentok.subscribe performance.stream, "publisher-container",
        width: $("#publisher-wrapper").width()
        height: $("#publisher-wrapper").height()

      $("##{subscriber.id}").addClass "publisher-object"
  
  onPerformanceCancel: (performance) ->
    if performance.user_id is showjo.user._id
      unpublish()
    
  onPerformanceEnd: (performance) ->
    if performance.user_id is showjo.user._id
      unpublish()      

unpublish = ->
  showjo.opentok.unpublish(showjo.opentok.publisher)

appendPublisher = ->
  $("<div />", 
    id: "publisher-container"
  ).appendTo("#publisher-wrapper")

$(document).ready ->    
  view = new View
    el: $("#stage")