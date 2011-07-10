exports.stageStartPerformer = (performance) ->  
  stageStart(performance)
  
  $("#empty-show").hide('fast')
  
  
  $("#voter > button").attr('disabled', 'disabled')
  $("#queue-wrapper").hide('fast')    
  $("#leave-queue-button-wrapper").hide('fast')
  
  # Show accept explanation
  $("#access-overlay").delay(2500).show('fast')
  
  $("#messages").toggleClass('performing', 'fast')
  
  # Start publishing stream
  publish()
  
exports.stageStartViewer = (performance) ->
  # Hide empty state stuff
  # $(".empty").hide('fast')
  # $(".empty-depend").toggleClass(".empty")
  
  stageStart(performance)
  
  # Show about to perform message

exports.performStartPerformer = (performance) ->
  performStart(performance)
  
  SS.server.performance.screenshot showjo.opentok.publisher.getImgData()
  
  # Show some sort of live notifications
  
exports.performStartViewer = (performance) ->
  performStart(performance)
  
  # Subscribe to the stream
  subscribe(performance.stream)

exports.performEndPerformer = (performance) ->
  performEnd(performance)
  endCancelPerformer(performance)

exports.performEndViewer = (performance) ->
  performEnd(performance)
  
exports.performCancelPerformer = (performance) ->
  performCancel(performance)
  endCancelPerformer(performance)
  
exports.performCancelViewer = (performance) ->
  performCancel(performance)

# Stage view updates for both performer and viewer  
stageStart = (performance) ->
  
  $(".empty-show").hide('fast')
  $("#performer-name").text(performance.name)
  $("#performer-description").text(performance.description)
  $("#nobody-on-stage").hide('fast')
  $("#performer-info").show('fast')
          
  # Check again to be sure the performance hasn't started
  if not performance.start_time?
    
    if performance.user_id is showjo.user.id
      $("#timer-message").text("You're about to go live!")
    else
      $("#timer-message").text("#{performance.name} is about to go live!")
    
    $("#timer-message").show('fast')
    
    resetTimer(SS.shared.constants.STAGE_LENGTH, false)
    $("#time-bar").removeClass('perform')
    $("#time-bar").addClass('stage')

    timers.stageStart(performance)
    $("#timer-wrapper").show('fast')

# Perform view updates for both performer and viewer    
performStart = (performance) ->  
  
  # Shows the performance rating
  $("#performance-rating-wrapper").show('fast')
  
  $("#timer-message").hide('fast')
  
  # Shows the performance timer
  showTimer = ->
    $("#time-bar").removeClass('stage')
    $("#time-bar").addClass('perform')
    # Set up the timer bar
    resetTimer(SS.shared.constants.PERFORM_LENGTH, true)
    $("#timer-wrapper").delay(500).show('fast')
  
  # If the stage timer is still visible, hide it first
  if $("#timer-wrapper").is(":visible")
    $("#timer-wrapper").hide 'fast', ->
      showTimer()
  else
    showTimer()

  timers.clear()
  timers.performStart(performance)

performEnd = (performance) ->
  performClear(performance)
  
performCancel = (performance) ->
  performClear(performance)
  
endCancelPerformer = (performance) ->
  $("#voter > button").removeAttr('disabled')
  $("#messages").toggleClass('performing', 'fast')
  $("#queue-wrapper").show('fast')
  $("#rock-mic-button-wrapper").show('fast')
  $("#access-overlay").hide('fast')
  unpublish()
  
performClear = (performance) ->
  # Hide the performance rating
  $("#performance-rating-wrapper").hide('fast')
  
  # Hide the timer bar
  console.log 'cleared'
  $("#timer-wrapper").hide 'fast'
  timers.clear()
  
  $("#performer-info").hide 'fast'# TODO: Make this a timed event, show a notification for some time
  if (SS.client.queue.count == 0)
    $(".empty-show").show 'fast', ->
      $(".empty-depend").addClass('empty', 500)
  
publish = () ->
  # Add event listener to tell the server when the user hits connect
  showjo.opentok.addEventListener "streamCreated", (event) ->
    for stream in event.streams
      do (stream) -> 
        if stream.connection.connectionId is showjo.opentok.connection.connectionId
          SS.client.analytics.track "Camera permission accepted"
          stageAcceptPerformer()
          SS.server.performance.publish stream, (response) ->

  appendPublisher()
  
  # Start publishing  
  showjo.opentok.publisher = showjo.opentok.publish "publisher-container",
    width: $("#publisher-wrapper").width()
    height: $("#publisher-wrapper").height()

  $("##{showjo.opentok.publisher.id}").addClass "publisher-object"

unpublish = () ->
  showjo.opentok.unpublish(showjo.opentok.publisher)

subscribe = (stream) ->
  appendPublisher()
  
  subscriber = showjo.opentok.subscribe stream, "publisher-container",
    width: $("#publisher-wrapper").width()
    height: $("#publisher-wrapper").height()

  $("##{subscriber.id}").addClass "publisher-object"

stageAcceptPerformer = (performer) ->
  # Hide the accept dialog
  $("#access-overlay").hide('fast')
  
appendPublisher = () ->
  $("<div />", 
    id: "publisher-container"
  ).appendTo("#publisher-wrapper")

resetTimer = (seconds, countup) ->
  time_total = SS.shared.time.getMinSec seconds
  
  if (countup)
    $("#time-bar").css('width', "0%")
  else
    $("#time-bar").css('width', "100%")

  $("#time-total .minutes").text(time_total.minutes)
  $("#time-total .seconds").text(SS.shared.time.pad(time_total.seconds,2))

  $("#time-passed .minutes").text("0")
  $("#time-passed .seconds").text("00")
  
timers = 

  stageStart: (performance) ->

    # Calculate the end time
    end_time = new Date()    
    start_time = new Date(performance.stage_time)
    
    end_time.setSeconds(start_time.getSeconds() + SS.shared.constants.STAGE_LENGTH)
    
    @timerPulsate = false
    @arrowPulsate = false
    
    id = setInterval =>
      # Get how much time is remaining
      time_span = new Date(end_time - new Date())    
      
      $("#time-passed .minutes").text(time_span.getMinutes())
      $("#time-passed .seconds").text(SS.shared.time.pad(time_span.getSeconds(), 2))
      
      percentage = ((time_span.getSeconds() + (time_span.getMinutes() * 60)) / SS.shared.constants.STAGE_LENGTH) * 100
      if percentage > 100
        percentage = 100
      $("#time-bar").css('width', "#{percentage}%")
      
      if not @arrowPulsate and (time_span.getSeconds() < 13)
        @arrowPulsate = true
        $("#arrow-up-img").effect("pulsate", {times: 3 }, 1000)
      
      if not @timerPulsate and (time_span.getSeconds() < 5)
        @timerPulsate = true
        $("#time-bar").effect("pulsate", { times: 10 }, 500)
      
      if percentage <= 0
        clearInterval(id)
         
    , 1000
    @ids.push id

  performStart: (performance) ->
        
    # Calculate the end time
    end_time = new Date()    
    start_time = new Date(performance.start_time)
    
    end_time.setSeconds(start_time.getSeconds() + SS.shared.constants.PERFORM_LENGTH)
    
    id = setInterval ->
      # Get how much time has elapsed
      time_span = new Date(new Date() - start_time)    
      
      $("#time-passed .minutes").text(time_span.getMinutes())
      $("#time-passed .seconds").text(SS.shared.time.pad(time_span.getSeconds(), 2))
      
      percentage = ((time_span.getSeconds() + (time_span.getMinutes() * 60)) / SS.shared.constants.PERFORM_LENGTH) * 100
      $("#time-bar").css('width', "#{percentage}%")

    , 1000
    @ids.push id
    
  # Clears all the timers  
  clear: () ->
    while @ids.length
      # POSSIBLE BUG: We might have left over ids in the array 
      # that are no longer active, clearing them might cause exception
      id = @ids.pop()
      clearInterval(id)

  # Holds the IDs of the timers so we can clear them if necessary  
  ids: []