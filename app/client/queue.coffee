# SS.client.queue

exports.join = ->
	name = $('#user_stage_name').val()
	description = $('#performance_desc').val()
	
	params = 
	  name: name
	  description: description
	
	SS.server.queue.join params, (response) ->
	  $("#join-queue-modal").trigger('reveal:close')
	  $("#rock-mic-button-wrapper}").hide('fast')
	  $("#leave-queue-button-wrapper").show('fast')
	  
exports.leave = ->
  SS.server.queue.leave (response) ->
    $("#leave-queue-button-wrapper").hide('fast')  

# Server event handlers
exports.init = (queue) ->
  $(".empty").hide('fast')
  renderQueue(queue)

exports.add = (performance) ->
  $(".empty").hide('fast')
  renderQueue(performance)
  
exports.remove = (performance) ->
  $("#queue-" + performance).hide('slow')
  $("#queue-" + performance).remove()
  
exports.stageView = () ->
  $("#queue-wrapper").hide('fast')
  $("#leave-queue-button-wrapper").hide('fast')  
  
exports.unstageView = () ->
  $("queue-wrapper").show('fast')
  $("#rock-mic-button-wrapper").show('fast')	

renderQueue = (performance) ->
  $("#templates-queue").tmpl(performance).hide().appendTo("#queue-list").show('slow')