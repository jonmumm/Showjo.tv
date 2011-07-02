# Client-side Code

# Bind to events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Bind client and server events
  bindClientEvents()
  bindServerEvents()

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    SS.client.app.user = response
    SS.server.app.requestState (response) ->    
    
bindClientEvents = ->
  $('#join-queue-button-wrapper').click ->
    SS.client.queue.join()
    
  $('#rock-mic-button-wrapper'}.click ->
    $('#join-queue-modal').reveal(
      animation: 'fadeAndPop'
      animationspeed: '300'
      closeonbackgroundclick: true
      dismissmodalclass: 'close-modal'
    )
    
bindServerEvents = ->
  SS.events.on 'queueInit', (data) -> SS.client.queue.init(data)
  SS.events.on 'queueAdd', (data) -> SS.client.queue.add(data)
  SS.events.on 'queueRemove', (data) -> SS.client.queue.remove(data)
