# SS.client.vote
exports.submit = (points) ->  
  SS.client.analytics.track "Vote submitted",
    points: points
  
  SS.server.vote.submit points, (response) =>
    # If the vote was successful, disable the button for 5 seconds
    if response
      
      # Disable the buttons
      $("#voter > button").attr('disabled', 'disabled')
      
      # Re-enable them after the delay
      timers.voteDelay()
    
timers = 
  voteDelay: () ->
    id = setTimeout =>
      $("#voter > button").removeAttr('disabled')
    , (SS.shared.constants.VOTE_DELAY_LENGTH * 1000)