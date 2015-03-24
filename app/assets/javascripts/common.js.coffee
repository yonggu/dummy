this.AwesomeCode =
  pollJob: (jobId, options)->
    options = options || {}

    $.poll options['interval'] || 1000, (retry)->
      $.getJSON "/jobs/" + jobId, (data)->
        switch data['status']
          when 'completed'
            if options['completed']
              options['completed'](data)
          when 'failed'
            if options['failed']
              options['failed'](data)
          else
            retry()

$ ->
  $('[data-toggle="tooltip"]').tooltip()

  url = document.location.toString()
  if url.match('#')
    $(".nav-tabs a[href=#tab-#{url.split('#')[1]}]").tab('show')
  $('.nav-tabs a').on 'shown.bs.tab', (e)->
    window.location.hash = e.target.hash.split('tab-')[1]
