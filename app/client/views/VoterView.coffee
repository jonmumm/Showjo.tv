View = Backbone.View.extend
  initialize: ->
    SS.events.on 'performance:cancel', @onPerformanceCancel
    SS.events.on 'performance:perform', @onPerformancePerform
    SS.events.on 'performance:perform:end', @onPerformanceEnd
  
  events:
    "click #lame-button-wrapper": "onLameClick"
    "click #awesome-button-wrapper": "onAwesomeClick"
  
  onLameClick: (event) ->
    SS.server.vote.submit -1, processVoteResponse
    
  onAwesomeClick: (event) ->
    SS.server.vote.submit 1, processVoteResponse 
    
  onPerformanceCancel: (performance) ->
    disableVote()
  
  onPerformanceEnd: (performance) ->
    disableVote()
    
  onPerformancePerform: (performance) ->
    if performance.user_id isnt showjo.user._id
      enableVote()

$(document).ready ->
  view = new View
    el: $("#voter")
    
disableVote = ->
  $("#voter > button").attr('disabled', 'disabled')
  
enableVote = ->
  $("#voter > button").removeAttr('disabled')

processVoteResponse = (response) ->
  if response.success
    disableVote()
    timers.voteDelay()
  
timers =
  voteDelay: () ->
    id = setTimeout =>
      enableVote()
    , (SS.shared.constants.VOTE_DELAY_LENGTH * 1000)
