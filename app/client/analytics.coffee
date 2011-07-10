exports.track = (event, properties = {}) ->
  
  if showjo.user.id
    properties.user_id = showjo.user.id
  
  mpmetrics.track event, properties