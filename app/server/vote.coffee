# SS.server.vote
exports.actions =
  submit: (points, cb) ->
    R.get "performance:current", (err, cur_perf_id) =>
      if not cur_perf_id?
        cb false
        return
        
      R.get "performance:#{cur_perf_id}", (err, performance) =>          
        performance = JSON.parse(performance)
        
        # Don't allow user to vote for self
        if performance.user_id is parseInt(@session.user_id)
          cb false
          return
        
        # Only process votes if the performance has started
        if not performance.start_time?
          cb false
          return
        
        R.incr "next:vote.id", (err, next_vote_id) =>
          vote_id = parseInt(vote_id)
          vote = 
            id: next_vote_id
            points: points
            user_id: @session.user_id
            performance_id: performance.id
            performer_id: performance.user_id
            vote_time: new Date().toString()
            
          R.set "vote:#{vote.id}", JSON.stringify(vote)
          
          R.rpush "performance:#{vote.performance_id}:votes", vote.id
          R.rpush "user:#{vote.user_id}:votes:submitted", vote.id
          R.rpush "user:#{vote.performer_id}:votes:received", vote.id
          
          cb true
    