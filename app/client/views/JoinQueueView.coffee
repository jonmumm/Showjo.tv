View = Backbone.View.extend
  initialize: ->
    $("#templates-join-queue-modal").tmpl().appendTo("body"); 

    $(document).bind 'joinQueueViewOpen', @render
    
  render: ->
    $("#performance_desc").val('')
    $('#join-queue-modal').reveal(
      animation: 'fadeAndPop'
      animationspeed: '300'
      closeonbackgroundclick: true
      dismissmodalclass: 'close-modal'
    )
    $('#user_stage_name').focus()
    
  events:
    "click #join-queue-button-wrapper": "joinQueueSubmit"
    
  joinQueueSubmit: ->
    
    params = 
      name: $('#user_stage_name').val()
      desc: $('#performance_desc').val()

    SS.server.queue.join params, (response) ->
      $("#join-queue-modal").trigger('reveal:close')

$(document).ready ->    
  view = new View
    el: $("#join-queue-modal")
