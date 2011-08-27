View = Backbone.View.extend
  initialize: ->
    SS.events.on 'message:chat', @onMessageChat
    SS.events.on 'message:alert', @onMessageAlert
    
    $(document).bind 'liveChatSend', @onLiveChatSend

  events:
    "keypress #enter_chat_text": "onKeyPress"
    
  onKeyPress: (e) ->
    if e.which is 13
      text = $("#enter_chat_text").val()
      if text isnt ''
        if showjo.user.name is "Anonymous" or not showjo.user.name?
          $(document).trigger 'enterNameViewOpen'
        else
          sendMessage()
  
  onLiveChatSend: () ->
    sendMessage()
    
  onMessageChat: (message) ->
    appendChat(message)
    
  onMessageAlert: (message) ->
    appendAlert(message)

$(document).ready ->    
  view = new View
    el: $("#live-chat")

appendAlert = (alert) ->
  $("#templates-alert").tmpl(alert).hide().prependTo("#messages").show 'fast'
    
appendChat = (chat) ->
  console.log 'chat111'
  console.log chat
  console.log '222'
  $("#templates-message").tmpl(chat).hide().prependTo("#messages").show 'fast'
  
sendMessage = ->
  console.log 'senddd'
  SS.server.message.chat $("#enter_chat_text").val(), (response) ->
    console.log response
    $("#enter_chat_text").val('')