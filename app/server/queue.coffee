exports.actions =

  join: (params, cb) ->    
    R.incr 'next:performance.id', (err, performanceId) =>     
      R.set "performance:#{performanceId}", JSON.stringify(params), (err, data) ->    
        params.id = performanceId    
        SS.publish.broadcast 'queueAdd', params      
      R.rpush "queue", performanceId
      R.rpush "user:#{@session.user_id}:performances", performanceId    
    cb true
  
  leave: () ->
    # Get this persons last performance
    R.lrange "performance:#{@session.user_id}:performances}", -1, (err, performanceId) =>
      R.lrem "queue", 0, performanceId, (err, removeCount) =>
        if removeCount > 0
          SS.publish.broadcast 'queueRemove', performanceId
    
    cb true      
    
  init: () ->
    R.lrange 'queue', 0, -1, (err, queueList) => 
      if queueList.length > 0
        keys = queueList.map (performance) -> "performance:#{performance}"
        R.mget keys, (err, queue) =>
          SS.publish.broadcast 'queueInit', queue.map (performance) -> JSON.parse(performance)