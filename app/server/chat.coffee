exports.actions = 
  message: (text, cb) ->
    # Get the user who sent it
    R.get "user:#{@session.user_id}", (err, user) =>
      if user
        user = JSON.parse(user)
        R.incr "next:message.id", (err, message_id) =>                            
          message = 
            id: message_id
            user_id: user.id
            speaker: user.name
            text: text
    
          R.set "message:#{message_id}", JSON.stringify(message)
          R.lpush "messages", message_id
          R.lpush "user:#{@session.user_id}:messages", message_id
    
          SS.publish.broadcast 'chatMessage', message
    
    cb true
    
  init: (user_id) ->
    # Get all messages
    R.lrange 'messages', 0, -1, (err, message_list) => 
      # If there is performances in the queue, get them all and send the back
      if message_list.length > 0
        keys = message_list.map (message_id) -> "message:#{message_id}"
        R.mget keys, (err, messages) =>
          SS.publish.user user_id, 'chatInit', messages.map (message) -> JSON.parse(message)
    
    # SS.publish.user @session.user_id, 'chatInit', messages