# SS.client.queue

exports.join = ->
	name = $('#user_stage_name').val()
	description = $('#performance_desc').val()
	
	params = 
	  name: name
	  description: description
	
	SS.server.queue.join params, (response) ->
	  $("#join-queue-modal").trigger('reveal:close')
	  


# Server event handlers
exports.init = (data) ->
  $("#queue .empty").hide('slow') 

exports.add = (data) ->
  #console.log data
  
exports.remove = (data) ->
  # console.log data