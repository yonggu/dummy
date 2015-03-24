$ ->
  $('.pull-request-btn, .push-directly-btn').on 'ajax:before', ->
    $(@).parent().isLoading(
      text:     "Loading",
      position: "overlay",
      class:    "glyphicon glyphicon-refresh"
    )

  $('.pull-request-btn, .push-directly-btn').on 'ajax:error', ->
    toastr.error 'Unexpected Error'
    $(@).parent().isLoading('hide')
