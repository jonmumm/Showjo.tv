exports.findInterval = (start_time, seconds) ->
  end_time = new Date()
  end_time.setSeconds(start_time.getSeconds() + seconds)
  return end_time.getTime() - start_time.getTime()