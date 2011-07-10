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
	  
	SS.client.analytics.track "Queue joined"
	  
exports.leave = ->
  SS.client.analytics.track "Queue left"
  
  SS.server.queue.leave (response) ->
    $("#leave-queue-button-wrapper").hide('fast')  
    $("#rock-mic-button-wrapper}").showSS('fast')

exports.count = 0

# Server event handlers
exports.init = (queue) ->
  $(".empty-show").hide('fast')
  $(".empty-depend").removeClass('empty', 500)
  @count += queue.length
  renderQueue(queue)

exports.add = (performance) ->
  $(".empty-show").hide('fast')
  $(".empty-depend").removeClass('empty', 500)
  renderQueue(performance)
  @count++
  
exports.remove = (performance) ->
  $("#queue-" + performance).hide('slow')
  $("#queue-" + performance).remove()
  @count--

renderQueue = (performance) ->
  $("#templates-queue").tmpl(performance).hide().appendTo("#queue-list").show('slow')