# Server-side Code

exports.actions =
  
  init: (cb) ->
    # If user doesn't have an id, get the next available one
    if !@session.user_id
      self = @
      R.incr 'next:user.id', (err, userId) =>
        if userId
          @session.setUserId(userId)          
          cb @session.user_id
        else
          cb false
    else
      cb @session.user_id
      
  requestState: (cb) ->        
    SS.server.queue.init()

            
    cb true