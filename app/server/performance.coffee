exports.actions = 
  tryNext: () ->
    R.get "performance:current", (err, cur_perf_id) =>
      if not cur_perf_id?
        # If there is no performance going on, get the top one in the queue
        R.lpop "queue", (err, next_perf_id) =>
          if next_perf_id?
            SS.publish.broadcast 'queueRemove', next_perf_id
            R.set "performance:current", next_perf_id          
            R.get "performance:#{next_perf_id}", (err, performance) =>
              stage JSON.parse(performance)
  
  # Sets the stream of the person about to perform
  publish: (stream, cb) ->
    R.get "performance:current", (err, cur_perf_id) =>
      if cur_perf_id?
        R.get "performance:#{cur_perf_id}", (err, performance) =>
           performance = JSON.parse(performance)
           if performance.user_id is @session.user_id          
            # Add the stream info to the performance
            performance.stream = stream
            R.set "performance:#{cur_perf_id}", JSON.stringify(performance)
    
    cb true

  # Whenever someone leaves, check if that person was currently performing
  # and cancel the performance if necessary
  leave: (cb) ->      
    # Check if the current performance is the person who requested to leave
    R.get "performance:current", (err, cur_perf_id) =>

      if cur_perf_id?
        R.get "performance:#{cur_perf_id}", (err, performance) =>
          performance = JSON.parse(performance)
          
          # If the leaving user is the performer, cancel it
          if performance.user_id is @session.user_id
            R.del "performance:current"
            SS.publish.broadcast 'performanceCancel', performance

  # Sends performance state to connecting client
  init: (user_id) ->
    R.get "performance:current", (err, cur_perf_id) ->
      if cur_perf_id?
        R.get "performance:#{cur_perf_id}", (err, performance) ->
          SS.publish.user user_id, 'performanceInit', JSON.parse(performance)

# Prepares the performer on stage
stage = (performance) ->    
  # Mark the time that the performer has come on stage
  performance.stage_time = new Date()
  R.set "performance:#{performance.id}", JSON.stringify(performance)

  # Tell everybody someone is on stage
  SS.publish.broadcast 'performanceStage', performance

  # Start a timer for when the staging period ends
  timers.stageEnd performance.stage_time, 10

# End of staging period, signal start of performance
stageEnd = () ->
  R.get "performance:current", (err, cur_perf_id) ->
    if cur_perf_id?
      R.get "performance:#{cur_perf_id}", (err, performance) ->
        perform JSON.parse(performance)

# Start the performance
perform = (performance) ->
  # Mark the performance start time
  performance.start_time = new Date()
  R.set "performance:#{performance.id}", JSON.stringify(performance)

  # Tell everyone someones performance is starting
  SS.publish.broadcast 'performanceStart', performance
  
  # Start a timer for when the performance ends
  timers.performEnd performance.start_time, 20

# End of performance, ask for next one
performEnd = () ->
  # Get the current performance
  R.get "performance:current", (err, cur_perf_id) =>

    if cur_perf_id?
      R.get "performance:#{cur_perf_id}", (err, performance) =>
        performance = JSON.parse(performance)
        SS.publish.broadcast 'performanceEnd', performance
        R.del "performance:current", (err, response) =>
          exports.actions.tryNext()

timers = 
  # Starts a timer to start the performance when staging time is over
  stageEnd: (stage_time, delay) ->
    interval = SS.shared.timers.findInterval(stage_time, delay)
    id = setTimeout stageEnd, interval
    @ids.push id

  # Starts a timer to end the performance  
  performEnd: (start_time, delay) ->
    interval = SS.shared.timers.findInterval(start_time, delay)
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