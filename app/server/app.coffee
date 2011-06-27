# Server-side Code

exports.actions =
  
  init: (cb) ->
    console.log @user
    cb 'Hello'
