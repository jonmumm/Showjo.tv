exports.actions =

  join: (params, cb) -> 
    # Get the next performance ID
    R.incr 'next:performance.id', (err, performanceId) =>
      params.id = performanceId  
      params.user_id = parseInt(@session.user_id)
      
      # Store the performance
      R.set "performance:#{performanceId}", JSON.stringify(params), (err, data) ->     
        SS.publish.broadcast 'queueAdd', params 
        
        alert = 
          speaker: params.name
          text: "has joined the queue."
        SS.publish.broadcast 'chatAlert', alert
      
      # Put the performance on the queue       
      R.rpush "queue", performanceId, (err, queueLength) ->
        
        if queueLength is 1
          SS.server.performance.tryNext()
      
      # Put the performance in the users list of performance    
      R.rpush "user:#{@session.user_id}:performances", performanceId  
      
    # Update the users name
    SS.server.user.setName.call @, params.name, ->
       
    cb true
  
  leave: (cb) ->
    console.log @session.user_id
    
    # Get this persons last performance
    R.lindex "user:#{@session.user_id}:performances", -1, (err, performance_id) =>
      
      # Check if that performance is currently in the queue
      R.lrem "queue", 0, performance_id, (err, remove_count) =>
        if remove_count > 0
          SS.publish.broadcast 'queueRemove', performance_id  
    cb true      
  
  # Sends queue state to connecting client  
  init: (user_id) ->
    
    # Get the entire queue
    R.lrange 'queue', 0, -1, (err, queueList) => 
      # If there is performances in the queue, get them all and send the back
      if queueList.length > 0
        keys = queueList.map (performance) -> "performance:#{performance}"
        R.mget keys, (err, queue) =>
          SS.publish.user user_id, 'queueInit', queue.map (performance) -> JSON.parse(performance)