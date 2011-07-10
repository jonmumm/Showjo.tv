exports.actions = 
  
  setName: (name, cb) ->
    R.get "user:#{@session.user_id}", (err, user) =>
      if user
        user = JSON.parse(user)  

        typeof user.id
        user.name = name
        R.set "user:#{@session.user_id}", JSON.stringify(user), (err, response) =>
          if response
            SS.publish.user @session.user_id, 'userUpdate', user
            cb true
          else
            cb false
      else
        cb false