exports.update = (user) ->
  showjo.user = user
  $("#user_stage_name").val(showjo.user.name)