# Client-side Code

window.showjo = {}
window.showjo.user = {}

# Bind to events
# SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
# SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  SS.server.app.init (response) ->
    if response.success?
      window.showjo.user = response.data
    else
      alert response.data

  # This is probabl not the best way to do it since it introduces the session connect delay
  # but will use this for now
  showjo.opentok = TB.initSession '28757622dbf26a5a7599c2d21323765662f1d436'
  showjo.opentok.connect '413302', 'devtoken'
  
  ###
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
  ###
    
bindClientEvents = ->
  
  $('#sign-up-link').click ->
    $("#launchrock-modal}").reveal()
  
  $('.feedback').click ->
    UserVoice.showPopupWidget();
    
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