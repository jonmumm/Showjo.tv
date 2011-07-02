# Server-side Code

exports.actions =
  
  init: (cb) ->
    
    # Bind disconnect cleanup events
    @session.on 'disconnect', (session) =>
      # Call these methods on @ (this) to get access to session var
      SS.server.queue.leave.call @, ->
      SS.server.performance.leave.call @, ->
    
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
    SS.server.queue.init(@session.user_id)
    SS.server.performance.init(@session.user_id)           
    cb true