# SS.client.performance

exports.init = (performance) ->
  
  # Stage the performance
  @stage(performance)
  
  # Start the performance if there has been a start time
  if performance.start_time?
    @start(performance)
  
exports.stage = (performance) ->
  # Update view for performer  
  if performance.user_id is showjo.user.id
    SS.client.view.stageStartPerformer(performance)
    # If we are the performer, publish our stream
  else
    SS.client.view.stageStartViewer(performance)
  
exports.start = (performance) ->
  if performance.user_id is showjo.user.id
    SS.client.view.performStartPerformer(performance)
    
    # console.log 'I am live!!'
  else
    console.log 'perform viewer'
    console.log performance
    SS.client.view.performStartViewer(performance)
    # If we are not the performer, subscribe to the stream
    # subscribe performance.stream
    
exports.end = (performance) ->
  if performance.user_id is showjo.user.id
    SS.client.view.performEndPerformer(performance)
  else
    SS.client.view.performEndViewer(performance)
    
exports.cancel = (performance) ->
  if performance.user_id is showjo.user.id
    SS.client.view.performCancelPerformer(performance)
  else
    SS.client.view.performCancelViewer(performance)