View = Backbone.View.extend
  initialize: ->
    $("#templates-save-modal").tmpl().appendTo("body"); 

    $(document).bind 'saveViewOpen', @render
    
  render: ->
    $('#save-modal').reveal(
      animation: 'fadeAndPop'
      animationspeed: '300'
      closeonbackgroundclick: true
      dismissmodalclass: 'close-modal'
    )
    
$(document).ready ->
  view = new View
    el: $("#save-modal")
