# Client-side Code

window.showjo = {}

# Bind to events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Bind client and server events
  bindClientEvents()
  bindServerEvents()
  
  showjo.opentok = TB.initSession '28757622dbf26a5a7599c2d21323765662f1d436'  

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    showjo.user = id: response
    
    showjo.opentok.addEventListener 'sessionConnected', (event) ->
      
      # Once connected to OpenTok, ask to initialize state
      SS.server.app.requestState (response) ->
    
    showjo.opentok.connect '413302', 'devtoken'
    
    # TOOD: Show loading message before we are connected to session
    
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
    
  $('#leave-queue-button-wrapper').click ->
    SS.client.queue.leave()

bindServerEvents = ->
  # Queue Events
  SS.events.on 'queueInit', (queue) -> SS.client.queue.init(queue)
  SS.events.on 'queueAdd', (performance) -> SS.client.queue.add(performance)
  SS.events.on 'queueRemove', (performance) -> SS.client.queue.remove(performance)
  
  # Performance Events
  SS.events.on 'performanceInit', (performance) -> SS.client.performance.init(performance)
  SS.events.on 'performanceStage', (performance) -> SS.client.performance.stage(performance)
  SS.events.on 'performanceStart', (performance) -> SS.client.performance.start(performance)
  SS.events.on 'performanceEnd', (performance) -> SS.client.performance.end(performance)
  SS.events.on 'performanceCancel', (performance) -> SS.client.performance.cancel(performance)