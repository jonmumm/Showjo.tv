count = 0

View = Backbone.View.extend
  initialize: ->
    SS.events.on 'queue:init', @onQueueInit
    SS.events.on 'queue:join', @onQueueJoin
    SS.events.on 'queue:leave', @onQueueLeave
    
  events:
    "click #rock-mic-button-wrapper": "onRockMicClick"
    "click #leave-queue-button-wrapper": "onLeaveQueueClick"
    
  onRockMicClick: (event) ->
    $(document).trigger 'joinQueueViewOpen'
  
  onLeaveQueueClick: (event) ->
    SS.server.queue.leave(->)
  
  onQueueInit: (performances) ->
    $.each performances, (index, performance) ->
      appendQueueItem(performance)    
    
  onQueueJoin: (performance) ->    
    if performance.user_id is showjo.user._id
      $("#rock-mic-button-wrapper}").hide('fast')
      $("#leave-queue-button-wrapper").show('fast')
    
    if count is 0
      $("#queue-empty").hide()    
    
    count++
    appendQueueItem(performance)   
  
  onQueueLeave: (performance) ->
    if performance.user_id is showjo.user._id
      $("#rock-mic-button-wrapper}").show('fast')
      $("#leave-queue-button-wrapper").hide('fast')
      
    count--
    $("#queue-" + performance._id).remove()
    
    if count is 0
      $("#queue-empty").show()

appendQueueItem = (item) ->
  $("#templates-queue").tmpl(item).hide().appendTo("#queue-list").show('slow')  

$(document).ready ->    
  view = new View
    el: $("#queue")