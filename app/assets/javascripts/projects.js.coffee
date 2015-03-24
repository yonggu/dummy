$ ->
  projectContainer = $('#project-container[data-url]')
  if projectContainer.length > 0
    url = projectContainer.data('url')
    $.get url, (data) ->
      $('#project-container .progress').replaceWith data
      list = new List('projects',
        valueNames: ['project_name']
      )

  $('form.rebuild-form').on 'ajax:before', ->
    $('input.rebuild-btn', @).button 'loading'

  $('form.rebuild-form').on 'ajax:success', (e, data, status, xhr) ->
    rebuildButton = $('input.rebuild-btn', @)
    AwesomeCode.pollJob data['job_id'],
      completed: (data) ->
        rebuildButton.button 'reset'
      failed: (data) ->
        rebuildButton.button 'reset'

  $("[type='checkbox'][name='projects_analysis_config[enabled]']").bootstrapSwitch()
  $("[type='checkbox'][name='projects_analysis_config[enabled]']").on 'switchChange.bootstrapSwitch', (event, state) ->
    $(@).parents('.projects_analysis_config_panel').isLoading(
      text:     "Loading",
      position: "overlay",
      class:    "glyphicon glyphicon-refresh"
    )
    form = $(@).closest('form')
    $.ajax(
      type: 'PUT'
      url: form.attr('action')
      datae: form.serializeArray()
      dateType: 'json'
    ).success((data, textStatus, jqXHR) =>
      $(@).parents('.projects_analysis_config_panel').isLoading('hide')
    ).error((jqXHR, textStatus, errorThrown) =>
      $(@).parents('.projects_analysis_config_panel').isLoading('hide')
      $(@).bootstrapSwitch('state', !state, true)
      toastr.error('Failed. Please try it later again.')
    )

  $(".bootstrap-switch").on 'click', (event) ->
    false

  $('.copy-button').tooltip
    container: 'body'
    title: 'Copy to clipboard'
    placement: 'bottom'
    animation: false


  $(document).on 'page:change', () ->
    client = new ZeroClipboard($('.copy-button'))
    client.on 'ready', (readyEvent) ->
      client.on 'aftercopy', (event) ->
        $(event.target).tooltip('hide').attr('data-original-title', 'Copied!').tooltip('fixTitle').tooltip('show')

  $(document).on 'page:before-change', () ->
    ZeroClipboard.destroy()
