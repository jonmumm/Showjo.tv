exports.actions = 
  
  getById: (id, cb) ->
    if id?
      M.User.findOne
        _id: id
      , (err, user) ->
        if err?
          cb
            success: false
            data: err
        else if not user?
          cb
            success: false
            data: "no user found"
        else
          cb
            success: true
            data: user
    else
      cb
        success: false
        data: "no user_id specified"
  
  setName: (name, cb) ->
    @getSession (session) ->
      SS.server.user.getById session.user_id, (response) ->
        if response.success?
          user = response.data
          user.name = name
          user.save (err) ->
            cb
              success: true
              data: user
        else
          cb
            success: false
            data: "no user found"