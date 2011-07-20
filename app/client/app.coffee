# Client-side Code

window.showjo = {}
window.showjo.user = {}

# Bind to events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

$(document).ready ->
  # SS.client.analytics.track "Page loaded"
  
  ###
  $("#connecting-modal").reveal(
    animation: 'fade'
    animationSpeed: '0'
    closeonbackgroundclick: false
  )
  
  setTimeout ->
    $("#connecting-message").fadeOut 'slow', ->
      $("#timeout").fadeIn 'slow'
  , 20000
  
  $("#connecting-message > p").effect "pulsate", 
    times: 10
  , 2000
  ###


# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->  
  
  # Bind client and server events
  bindClientEvents()
  bindServerEvents()
  
  showjo.opentok = TB.initSession '28757622dbf26a5a7599c2d21323765662f1d436'  

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    showjo.user = response
    SS.client.analytics.track "User initialized"
    
    populateUserInfo(showjo.user)
    
    showjo.opentok.addEventListener 'sessionConnected', (event) ->
      $("#connecting-modal").trigger("reveal:close")
      
      SS.client.analytics.track "OpenTok connected"
      
      # Once connected to OpenTok, ask to initialize state
      SS.server.app.requestState (response) ->
    
    showjo.opentok.connect '413302', 'devtoken'
    
    # TOOD: Show loading message before we are connected to session
    
bindClientEvents = ->
  
  $('#join-queue-button-wrapper').click ->
    SS.client.queue.join()
  
  showQueueModal = ->
    SS.client.analytics.track "Rock mic clicked"
    $("#performance_desc").val('')
    $('#join-queue-modal').reveal(
      animation: 'fadeAndPop'
      animationspeed: '300'
      closeonbackgroundclick: true
      dismissmodalclass: 'close-modal'
    )
    $('#user_stage_name').focus()
  
  # Show the feedback button 7 seconds in to page load
  setTimeout ->
    $("#feedback").slideDown 'fast'
  , 7000
  
  $('#sign-up-link').click ->
    $("#launchrock-modal}").reveal()
  
  $('.feedback').click ->
    UserVoice.showPopupWidget();
    
  $('#rock-mic-button-wrapper'}.click ->
    showQueueModal()
    
  $("#could-be").click ->
    showQueueModal()
    
  $('#leave-queue-button-wrapper').click ->
    SS.client.queue.leave()
   
  $('input[type=text]').keypress (e) ->
    if e.which is 13
      e.preventDefault()
  
  $("#lame-button-wrapper").click ->
    SS.client.vote.submit(-1)
    
  $("#awesome-button-wrapper").click ->
    SS.client.vote.submit(1) 
    
  $('#enter_chat_text').keypress (e) ->    
    if e.which is 13
      text = $(@).val()
      if text isnt ''
        SS.client.chat.send text
      $(@).val('')

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
  
  # User Events
  SS.events.on 'userUpdate', (user) -> SS.client.user.update(user)
  
  # Chat Events
  SS.events.on 'chatInit', (messages) -> SS.client.chat.init(messages)
  SS.events.on 'chatMessage', (message) -> SS.client.chat.message(message)
  SS.events.on 'chatAlert', (alert) -> SS.client.chat.alert(alert)
  
  # Vote Events
  SS.events.on 'ratingInit', (ratings) -> SS.client.rating.init(ratings)
  SS.events.on 'ratingUpdate', (rating) -> SS.client.rating.update(rating)
  
populateUserInfo = (user) ->
  if user.name?
    $("#user_stage_name").val(user.name)