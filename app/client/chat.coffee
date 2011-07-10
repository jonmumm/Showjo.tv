exports.send = (text) ->
  SS.client.analytics.track "Chat entered"
  
  if showjo.user.name?
    # Just send the message
    SS.server.chat.message text, (response) ->
  else
    # Ask for the users name
    $("#enter-name-modal").reveal
      animation: 'fade'
      animationspeed: '100'
      closeonbackgroundclick: true      
    $("#user_chat_name").focus()
    
    enterName = (name) ->
      # TODO: Validate
      if name isnt ''
        $("#enter-name-modal").trigger('reveal:close')
        SS.server.user.setName name, (response) ->
          if response
            SS.server.chat.message text, (response) ->
    
    $("#user_chat_name").keypress (e) ->
      if e.which is 13
        e.preventDefault()
        enterName $(@).val()
        
    $("#enter-name-button-wrapper").click ->
      enterName $("#user_chat_name").val()

exports.message = (message) ->
  renderMessage(message)
  
exports.init = (messages) ->
  renderMessage(messages)
  
exports.alert = (alert) ->
  $("#templates-alert").tmpl(alert).hide().prependTo("#messages").show 'fast'
  
renderMessage = (message) ->  
  $("#templates-message").tmpl(message).hide().prependTo("#messages").show 'fast'
    
# anchorScroll = () ->
  # scrollDiv = document.getElementById 'messages'
  # scrollDiv.scrollTop = scrollDiv.scrollHeight