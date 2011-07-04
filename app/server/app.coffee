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
      R.incr 'next:user.id', (err, user_id) =>
        if user_id
          @session.setUserId(user_id)
          # Create a new user and store it
          user = 
            id: user_id
          R.set "user:#{user_id}", JSON.stringify(user), (err, response) =>
            if response
              getUser @session.user_id, cb
        else
          cb false
    else
      getUser @session.user_id, cb
      
  requestState: (cb) ->                
    SS.server.queue.init(@session.user_id)
    SS.server.performance.init(@session.user_id) 
    SS.server.chat.init(@session.user_id)          
    cb true
    
getUser = (user_id, cb) ->
  R.get "user:#{user_id}", (err, user) =>
    if user?
      cb JSON.parse(user)
    else
      cb false