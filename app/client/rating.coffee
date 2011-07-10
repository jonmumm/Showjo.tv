exports.init = (ratings) ->
  console.log ratings

  for rating in ratings
    do (rating) ->
      point = [ data[0].length, rating ]
      data[0].push( point )

  renderPlot()
  
exports.update = (rating) ->
  point = [ data[0].length, rating ]
  data[0].push( point )
  
  renderPlot()
  
data = [[]]

exports.clear = () ->
  data = [[]]

renderPlot = () ->
  $.jqplot 'performance-plot', data,
    axesDefaults:
      autoScale: false      
      showTicks: false
    axes:
      xaxis:
        min: 0
        max: (SS.shared.constants.PERFORM_LENGTH * 1000 / SS.shared.constants.RATING_CALC_LENGTH)  
      yaxis:
        min: -5
        max: 10
    seriesDefaults:
      markerOptions:
        show: false
    grid:      
      shadow: false
      drawGridlines: false
      drawBorder: false