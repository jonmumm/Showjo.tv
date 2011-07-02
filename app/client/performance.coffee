# SS.client.performance

exports.init = (performance) ->
  # If the performance doesn't have a start time, it is still being staged
  if performance.start_time?
    @start(performance)
  else
    @stage(performance)
  
exports.stage = (performance) ->

  # Update view for performer
  $("#templates-publisher").tmpl().appendTo "#stage"  
  $("#templates-upnow").tmpl(performance).appendTo "#performer"
  SS.client.queue.stageView()
  SS.client.vote.stageView()
  
  if performance.user_id is showjo.user.id
    # If we are the performer, publish our stream
    publish()
  else
    # console.log 'this is somebody elses'
  
exports.start = (performance) ->
  if performance.user_id is showjo.user.id
    console.log 'I am live!!'
  else
    # If we are not the performer, subscribe to the stream
    subscribe performance.stream
    
exports.end = (performance) ->
  SS.client.queue.unstageView()
  SS.client.vote.unstageView()
    
exports.cancel = (performance) ->
  SS.client.queue.unstageView()
  SS.client.vote.unstageView()
  
publish = () ->
  # Add event listener to tell the server when the user hits connect
  showjo.opentok.addEventListener "streamCreated", (event) ->
    for stream in event.streams
      do (stream) -> 
        if stream.connection.connectionId is showjo.opentok.connection.connectionId
          SS.server.performance.publish stream, (response) ->
            console.log response
  
  # Start publishing
  publisher = showjo.opentok.publish "publisher-container",
    width: $("#publisher-wrapper").width()
    height: $("#publisher-wrapper").height()
  
  $("##{publisher.id}").addClass "publisher-object"
  
subscribe = (stream) ->
  subscriber = showjo.opentok.subscribe stream, "#publisher-container",
    width: $("#publisher-wrapper").width()
    height: $("#publisher-wrapper").height()
    
  $("##{subscriber.id}").addClass "publisher-object"