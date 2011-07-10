exports.actions =

  init: (user_id) ->
    R.get "performance:current", (err, cur_perf_id) ->
      if not cur_perf_id?
        return
      
      R.lrange "performance:#{cur_perf_id}:ratings", 0, -1, (err, ratings) =>
        if ratings
          SS.publish.user user_id, 'ratingInit', ratings

  start: (performance) ->
    timers.startCalculate(performance)
    
  stop: () ->
    timers.clear()

timers = 
  # Starts a timer to start the performance when staging time is over
  startCalculate: (performance) ->
    id = setInterval ->
      addNewRating(performance)
    , SS.shared.constants.RATING_CALC_LENGTH
    @ids.push id

  # Clears all the timers  
  clear: () ->
    while @ids.length
      id = @ids.pop()
      clearInterval(id)

  # Holds the IDs of the timers so we can clear them if necessary  
  ids: []

addNewRating = (performance) ->
  
  rating = 0
  sendUpdate = ->
    R.rpush "performance:#{performance.id}:ratings", rating  
    SS.publish.broadcast "ratingUpdate", rating
  
  # Calculate the rating based on all the votes
  R.lrange "performance:#{performance.id}:votes", 0, -1, (err, vote_ids) =>

    if not vote_ids.length >= 1
      rating = 0
      sendUpdate()
    else
      # Get the DB keys for all the votes
      keys = vote_ids.map (vote_id) -> "vote:#{vote_id}"
      R.mget keys, (err, votes) =>
        console.log 'votes'
        console.log votes
        for vote in votes
          do (vote) ->
            vote = JSON.parse(vote)
            rating += vote.points
        sendUpdate()
  

 
            