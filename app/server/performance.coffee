exports.actions = 

  create: (id, performance, cb = =>) ->
    R.set "performance:#{id}", performance, (err, response) =>
      if not err then cb true else cb false
  
  read: (id, cb) ->
    R.get "performance:#{id}", (err, performance) =>
      if not err then cb JSON.parse(performance) else cb err      

  update: (performance, cb = =>) ->
    R.set "performance:#{performance.id}", JSON.stringify(performance), (err, response) =>
      if not err then cb true else cb false

  delete: (id, cb = =>) ->
    R.del "performance:#{id}", (err, response) =>
      if not err then cb response else cb err
  
  current: (cb) -> 
    @currentId (id) =>
      @read id, (performance) =>
        cb performance
  
  currentId: (cb) ->
    R.get "performance:current", (err, cur_perf_id) =>
      if not err then cb cur_perf_id else cb err    
      
  tryNext: () ->
    @currentId (cur_perf_id) =>
      if not cur_perf_id?
        # If there is no performance going on, get the top one in the queue
        R.lpop "queue", (err, next_perf_id) =>
          if next_perf_id?
            SS.publish.broadcast 'queueRemove', next_perf_id
            R.set "performance:current", next_perf_id   
            @read next_perf_id, (performance) =>
              stage performance       
  
  # Sets the stream of the person about to perform
  publish: (stream, cb) ->
    @current (performance) => 
      if performance.user_id is parseInt @session.user_id
        performance.stream = stream        
        @update performance       
        cb true
      else
        cb false

  # Whenever someone leaves, check if that person was currently performing
  # and cancel the performance if necessary
  leave: (cb) -> 
    # Check if the current performance is the person who requested to leave
    SS.server.performance.current (performance) =>
      if not performance?
        return
        
      # If the leaving user is the performer, cancel it
      if performance.user_id is parseInt(@session.user_id)
        SS.server.performance.delete "current"
        SS.publish.broadcast 'performanceCancel', performance
      
        timers.clear()
        SS.server.rating.stop()
      
        # Send chat alert
        alert = 
          speaker: performance.name
          text: "has cancelled the performance."
        SS.server.chat.alert alert

  screenshot: (data, cb) ->
    buffer = new Buffer data, 'base64'
    console.log data.length, buffer.length
    require('fs').writeFileSync('image.jpg', buffer, 0, buffer.length)

  # Sends performance state to connecting client
  init: (user_id) ->
    exports.actions.current (performance) =>
      if performance? 
        SS.publish.user user_id, 'performanceInit', performance

# Prepares the performer on stage
stage = (performance) ->    
  # Mark the time that the performer has come on stage

  performance.stage_time = new Date().toString()
  R.set "performance:#{performance.id}", JSON.stringify(performance)

  # Tell everybody someone is on stage
  SS.publish.broadcast 'performanceStage', performance
  
  alert = 
    speaker: performance.name
    text: "is coming on stage."
  SS.publish.broadcast 'chatAlert', alert

  # Start a timer for when the staging period ends
  timers.stageEnd performance

# End of staging period, try to start performance
stageEnd = () ->
  exports.actions.current (performance) =>
    perform performance

# Start the performance if stream exists
perform = (performance) ->
  if performance.stream?  
    # Mark the performance start time
    performance.start_time = new Date().toString()
    performance.length_sec = SS.shared.constants.PERFORM_LENGTH
    exports.actions.update performance

    # Tell everyone someones performance is starting
    SS.publish.broadcast 'performanceStart', performance
    
    alert = 
      speaker: performance.name
      text: "is performing now!"
    SS.server.chat.alert(alert)
  
    # Start the rating calculator
    SS.server.rating.start(performance)
  
    # Start a timer for when the performance ends
    timers.performEnd performance
  else
    exports.actions.delete "current"
    SS.publish.broadcast 'performanceCancel', performance
    alert = 
      speaker: performance.name
      text: "has cancelled the performance."
    SS.publish.broadcast 'chatAlert', alert

# End of performance, ask for next one
performEnd = () ->
  exports.actions.current (performance) =>

    SS.publish.broadcast 'performanceEnd', performance
  
    # Stop the rating calculator
    SS.server.rating.stop()
  
    # Send chat alert
    alert = 
      speaker: performance.name
      text: "has finished performing."
    SS.publish.broadcast 'chatAlert', alert
  
    # Remove current from DB and start next
    exports.actions.delete "current", (response) =>
      exports.actions.tryNext()

timers = 
  # Starts a timer to start the performance when staging time is over
  stageEnd: (performance) ->
    interval = SS.shared.time.findInterval(performance.stage_time, SS.shared.constants.STAGE_LENGTH)
    id = setTimeout stageEnd, interval
    @ids.push id

  # Starts a timer to end the performance  
  performEnd: (performance) ->
    interval = SS.shared.time.findInterval(performance.start_time, SS.shared.constants.PERFORM_LENGTH)
    id = setTimeout performEnd, interval
    @ids.push id

  # Clears all the timers  
  clear: () ->
    while @ids.length
      # POSSIBLE BUG: We might have left over ids in the array 
      # that are no longer active, clearing them might cause exception
      id = @ids.pop()
      clearTimeout(id)

  # Holds the IDs of the timers so we can clear them if necessary  
  ids: []