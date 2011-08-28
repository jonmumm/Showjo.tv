exports.actions =

  getById: (id, cb) ->
    if id?
      M.Performance.findOne
        _id: id
      , (err, performance) ->
        if err?
          cb
            success: false
            data: err
        else if not performance?
          cb
            success: false
            data: "no performance found"
        else
          cb
            success: true
            data: performance
    else
      cb
        success: false
        data: "no performance_id specified"
  
  getCurrent: (cb) ->
    R.get "performance:current", (err, cur_perf_id) =>      
      if not cur_perf_id?
        cb
          success: false
          data: "no current performance"
      else
        @getById cur_perf_id, cb
  
 
  # Sets the stream of the person about to perform
  publish: (stream, cb) ->
    @getCurrent (response) =>
      console.log response
      if response.success
        console.log 'about to save'
        performance = response.data
        performance.stream = stream
        console.log performance
        performance.save (response) ->
          console.log 'saving??'
          console.log response
          cb true 
      else
        cb false

  ###
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
    ###


SS.events.on 'client:init', (session) ->
  SS.server.performance.getCurrent (response) ->
    if response.success
      performance = response.data
      SS.publish.user session.user_id, 'performance:init', performance
      if performance.performed_at?
        SS.publish.user session.user_id, 'performance:perform', performance
      else
        SS.publish.user session.user_id, 'performance:stage', performance


SS.events.on 'client:disconnect', (session) ->
  session._findOrCreate (session) ->
    R.get "user:#{session.user_id}:last_performance", (err, performance_id) ->
      if performance_id?
        R.get "performance:current", (err, cur_perf_id) ->
          if performance_id is cur_perf_id
            SS.server.performance.getById cur_perf_id, (response) ->
              if response.success
                SS.publish.broadcast 'performance:cancel', response.data
                SS.events.emit 'performance:cancel', response.data

SS.events.on 'performance:next', (performance) ->
  performance.staged_at = Date.now()
  performance.save()

  SS.publish.broadcast 'performance:init', performance
  SS.events.emit 'performance:init', performance

  SS.publish.broadcast 'performance:stage', performance
  SS.events.emit 'performance:stage', performance

SS.events.on 'performance:stage', (performance) ->
  timers.stageEnd performance

SS.events.on 'performance:stage:end', (perf) ->
  M.Performance.findOne
    _id: perf._id
  , (err, performance) ->
    console.log performance
    if performance.stream?
      performance.performed_at = Date.now()
      performance.length_sec = SS.shared.constants.PERFORM_LENGTH
      performance.save()

      SS.publish.broadcast 'performance:perform', performance
      SS.events.emit 'performance:perform', performance
    else
      R.del "performance:current", (err, remove_count) ->
        SS.publish.broadcast 'performance:cancel', performance
        SS.events.emit 'performance:cancel', performance

SS.events.on 'performance:perform', (performance) ->
  timers.performEnd performance

SS.events.on 'performance:perform:end', (performance) ->
  M.Performance.findOne
    _id: performance.id
  , (err, performance) ->
    R.del "performance:current", (err, remove_count) ->  
      SS.publish.broadcast 'performance:perform:end', performance
      SS.events.emit 'performancee:perform:end', performance

timers = 
  # Starts a timer to start the performance when staging time is over
  stageEnd: (performance) ->
    interval = SS.shared.time.findInterval(performance.staged_at, SS.shared.constants.STAGE_LENGTH)
    id = setTimeout ->
      SS.events.emit 'performance:stage:end', performance
    , interval
    @ids.push id

  # Starts a timer to end the performance  
  performEnd: (performance) ->
    interval = SS.shared.time.findInterval(performance.performed_at, SS.shared.constants.PERFORM_LENGTH)
    id = setTimeout ->
      SS.events.emit 'performance:perform:end', performance
    , interval
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
