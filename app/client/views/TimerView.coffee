# TODO: Fix timer for mid stage joins

View = Backbone.View.extend
  initialize: ->
    SS.events.on 'performance:stage', @onPerformanceStage    
    SS.events.on 'performance:cancel', @onPerformanceCancel
    SS.events.on 'performance:perform', @onPerformancePerform
    SS.events.on 'performance:perform:end', @onPerformanceEnd
    
  onPerformanceStage: (performance) ->
    if performance.user_id is showjo.user._id
      $("#timer-message").text("You're about to go live!")
    else
      $("#timer-message").text("#{performance.name} is about to go live!")
      
    $("#timer-message").show('fast')

    resetTimer(SS.shared.constants.STAGE_LENGTH, false)
    $("#time-bar").removeClass('perform')
    $("#time-bar").addClass('stage')

    timers.stageStart(performance)
    $("#timer-wrapper").show('fast')
    
  onPerformanceCancel: (performance) ->
    clearTimer()
  
  onPerformanceEnd: (performance) ->
    clearTimer()
    
  onPerformancePerform: (performance) ->
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

$(document).ready ->    
  view = new View
    el: $("#timer")

clearTimer = ->
  $("#timer-wrapper").hide 'fast'
  timers.clear()

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
    start_time = new Date(performance.staged_at)

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
    start_time = new Date(performance.performed_at)

    end_time.setSeconds(start_time.getSeconds() + SS.shared.constants.PERFORM_LENGTH)

    id = setInterval ->
      # Get how much time has elapsed
      time_span = new Date(new Date() - start_time)    

      $("#time-passed .minutes").text(time_span.getMinutes())
      $("#time-passed .seconds").text(SS.shared.time.pad(time_span.getSeconds(), 2))

      percentage = ((time_span.getSeconds() + (time_span.getMinutes() * 60)) / SS.shared.constants.PERFORM_LENGTH) * 100

      if percentage > 100
        percentage = 100

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