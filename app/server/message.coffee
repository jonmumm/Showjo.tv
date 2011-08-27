exports.actions = 
  chat: (text, cb) ->
    @getSession (session) ->
      SS.server.user.getById session.user_id, (response) ->
        if response.success?
          user = response.data
                    
          message = new M.Message
            user_id: user._id
            name: user.name
            message: text
            type: "chat"
          message.save()
            
          SS.publish.broadcast 'message:chat', message  
          cb
            success: true
            data: message
        else
          cb
            success: true
            data: "no user found"
    
  alert: (alert, cb = =>) ->
    SS.publish.broadcast 'chatAlert', alert
  
  ###
    
  init: (user_id) ->
    # Get all messages
    R.lrange 'messages', -12, -1, (err, message_list) => 
      # If there is performances in the queue, get them all and send the back
      if message_list.length > 0
        keys = message_list.map (message_id) -> "message:#{message_id}"
        R.mget keys, (err, messages) =>
          SS.publish.user user_id, 'chatInit', messages.map (message) -> JSON.parse(message)
    ###
    
    # SS.publish.user @session.user_id, 'chatInit', messages