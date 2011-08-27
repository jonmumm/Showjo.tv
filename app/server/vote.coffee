# SS.server.vote
exports.actions =
  submit: (points, cb) ->
    SS.server.performance.getCurrent (response) ->
      if response.success?
        @getSession (session) ->          
          # Don't allow user to vote for self
          if performance.user_id is session.user_id
            cb
              success: false
              data: "can't vote for yourself"
            return
        
          # Only process votes if the performance has started
          if not performance.performed_at?
            cb
              success: false
              data: "can't vote on performance that hasn't started"
          
          performance = response.data
          
          vote = 
            points: points #TODO: Validate points somehow
            user_id: session.user_id
            performer_id: performance.user_id

          performance.votes.push vote
          
          performance.save (err) ->
            SS.events.emit 'vote:submit', vote
            
          cb
            success: true
            data: vote
      else
        cb
          success: false
          data: "no current performance"
