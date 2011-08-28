View = Backbone.View.extend
  initialize: ->
    $("#templates-enter-name-modal").tmpl().appendTo("body")

    $(document).bind 'enterNameViewOpen', @render
  
  render: ->
    $("#enter-name-modal").reveal
      animation: 'fade'
      animationspeed: '100'
      closeonbackgroundclick: true      
    $("#user_chat_name").focus()

  events:
    "keypress #user_chat_name": "onKeyPress"
    "click #enter-name-button-wrapper": "onEnterClick"
  
  onKeyPress: (e) ->
    if e.which is 13
      e.preventDefault()
      enterName $("#user_chat_name").val()
    
  onEnterClick: ->
    enterName $("#user_chat_name").val()  
    
enterName = (name) ->
  # TODO: Validate
  if name isnt ''
    $("#enter-name-modal").trigger('reveal:close')
    SS.server.user.setName name, (response) ->
      if response.success
        showjo.user = response.data
        $(document).trigger 'liveChatSend'

$(document).ready ->    
  view = new View
    el: $("#enter-name-modal")
