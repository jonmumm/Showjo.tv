View = Backbone.View.extend
  initialize: ->
    if not showjo.connected
      $("#templates-connecting-modal").tmpl().appendTo("body")

      SS.socket.on 'connect', @closeDialog

      @render()
    
  render: ->
    # if SS.env is "production"
    $("#connecting-modal").reveal(
      animation: 'fade'
      animationSpeed: '0'
      closeonbackgroundclick: false
    )

    setTimeout ->
      $("#connecting-message").fadeOut 'slow', ->
        $("#timeout").fadeIn 'slow'
    , 20000

    $("#connecting-message > p").effect "pulsate",
      times: 10
    , 2000
    
  closeDialog: ->
    $("#connecting-modal").trigger "reveal:close"

$(document).ready ->
  view = new View
