exports.findInterval = (start_time_string, seconds) ->
  start_time = new Date(start_time_string)
  end_time = new Date()
  end_time.setSeconds(start_time.getSeconds() + seconds)
  return end_time.getTime() - start_time.getTime()
  
exports.pad = (number, length) ->
  str = '' + number
  while (str.length < length)
    str = '0' + str
    
  return str
  
exports.getMinSec = (seconds) ->
  minutes = Math.floor(seconds / 60)
  seconds = seconds % 60

  time = 
    minutes: minutes
    seconds: seconds

  return time