# Server-side Events
# ------------------
# Uncomment these events to run your own custom code when events are fired

###
SS.events.on 'client:connect', (user_id) ->
  console.log "USER_ID #{user_id}"
  console.log 'hi'
  # SS.publish.user user_id, 'hi', 'asdfafewf'
###

#SS.events.on 'client:heartbeat', (session) ->
#  console.log "The client with session_id #{session.id} is still alive!"

#SS.events.on 'client:disconnect', (session) ->
#    console.log session.user_id