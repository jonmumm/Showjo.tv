exports.actions =
	join: (params, cb = ->) ->
		@getSession (session) ->
			SS.server.user.getById session.user_id, (response) ->
				if response.success
					user = response.data
					user.name = params.name
					user.save()

					performance = new M.Performance
						user_id: user._id
						name: params.name
						desc: params.desc

					performance.save (err) ->
						if err?
							cb
								success: false
								data: err
						else
							R.rpush "queue", performance._id, (err, length) ->
								if err?
									cb
										success: false
										data: err
								else
									cb
										success: true
										data: performance
									R.set "user:#{user._id}:last_performance", performance._id
									session.attributes.last_performance = performance._id
									SS.events.emit 'queue:join', performance
									SS.publish.broadcast 'queue:join', performance

				else
					cb response

	leave: (cb) ->
	  @getSession (session) ->
	    R.get "user:#{session.user_id}:last_performance", (err, performance_id) ->
	      if err?
	        cb
	          success: false
	          response: err
	      else if not performance_id?
	        cb
	          success: false
	          response: "not in queue"
	      else
	        remove performance_id, cb

SS.events.on 'client:connect', (session) ->
  R.lrange 'queue', 0, -1, (err, performance_ids) =>
    M.Performance.find
      _id:
        $in: performance_ids
    , (err, queue) ->
      if queue?
        SS.publish.user session.user_id, 'queue:init', queue


SS.events.on 'client:disconnect', (session) ->
  session._findOrCreate (session) ->
    R.get "user:#{session.user_id}:last_performance", (err, performance_id) ->
      if performance_id?
        remove performance_id, (response) -> # remove performance form the queue

SS.events.on 'queue:join', (performance) ->
	next()

SS.events.on 'performance:cancel', (performance) ->
	next()

SS.events.on 'performance:perform:end', (performance) ->
	next()

next = () ->
	R.get "performance:current", (err, cur_perf_id) ->
		if not cur_perf_id?
			R.lpop "queue", (err, next_perf_id) =>
			  if next_perf_id?
  			  M.Performance.findOne
  			    _id: next_perf_id
  			  , (err, performance) ->

  			    if performance?
  			      SS.publish.broadcast 'queue:leave', performance
  			      SS.events.emit 'queue:leave', performance

  			      R.set "performance:current", performance._id, (err, success) ->
    			      SS.events.emit 'performance:next', performance

remove = (id, cb = ->) ->
	R.lrem "queue", 0, id, (err, remove_count) =>
		if remove_count < 1
			cb
				success: false
				data: "no performance to remove"
		else
			SS.publish.broadcast 'queue:leave', id
			SS.events.emit 'queue:leave', id
			cb
				success: true
				data:
					id: id