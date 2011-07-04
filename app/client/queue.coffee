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
    $("#rock-mic-button-wrapper}").show('fast')

# Server event handlers
exports.init = (queue) ->
  $(".empty-show").hide('fast')
  $(".empty-depend").removeClass('empty', 500)
  renderQueue(queue)

exports.list = []

exports.add = (performance) ->
  $(".empty-show").hide('fast')
  $(".empty-depend").removeClass('empty', 500)
  #$(".empty-show-depend").toggleClass('empty', 'fast')
  renderQueue(performance)
  @list[performance.id] = performance
  
exports.remove = (performance) ->
  $("#queue-" + performance).hide('slow')
  $("#queue-" + performance).remove()
  delete @list[performance.id]

renderQueue = (performance) ->
  $("#templates-queue").tmpl(performance).hide().appendTo("#queue-list").show('slow')