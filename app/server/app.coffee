# Server-side Code

exports.actions =
  
  init: (cb = ->) ->
    SS.server.user.getById @session.user_id, (response) =>
      if response.success
        user = response.data
        SS.events.emit 'client:connect', @session # TODO: Put this after setUserId callback 
      else
        user = new M.User()
        user.save()
        @session.setUserId user._id, ->
          SS.events.emit 'client:connect', @session # TODO: Put this after setUserId callback                     
      cb 
        success: true
        data: user
    
    # Bind disconnect cleanup events
    
    ###
    @session.on 'disconnect', (session) =>
      # Call these methods on @ (this) to get access to session var
      SS.server.queue.leave.call @, ->
      SS.server.performance.leave.call @, ->
    
    # If user doesn't have an id, get the next available one
    if !@session.user_id
      R.incr 'next:user.id', (err, user_id) =>
        if user_id
          user_id = parseInt(user_id)
          @session.setUserId user_id
          # Create a new user and store it
          user = 
            id: user_id
          R.set "user:#{user_id}", JSON.stringify(user), (err, response) =>
            if response
              getUser @session.user_id, cb
        else
          cb false
    else
      # @session.setUserId @session.user_id
      # BUG: Returning users arent publishg streaming correct
      getUser @session.user_id, cb
    ###
  
  ###    
  requestState: (cb) -> 
    SS.server.queue.init(@session.user_id)
    SS.server.performance.init(@session.user_id)
    SS.server.chat.init(@session.user_id)
    # SS.server.rating.init(@session.user_id)
    cb true
    ###

###    
getUser = (user_id, cb) ->
  console.log user_id
  
  R.get "user:#{user_id}", (err, user) =>
    if user?
      cb JSON.parse(user)
    else
      cb false
      
  