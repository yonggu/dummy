module BuildsHelper

  def build_html_class(build)
    case build.aasm_state.to_sym
    when :completed
      if build.success?
        if build.recovered?
          :recovered
        else
          :success
        end
      else
        :failed
      end
    when :failed
      :error
    else
      build.aasm_state.to_sym
    end
  end

  def build_state_tag(build)
    case build.aasm_state.to_sym
    when :running
      content_tag :span, 'RUNNING', class: 'label label-info'
    when :completed
      if build.success?
        if build.recovered?
          content_tag :span, 'RECOVERED', class: 'label label-primary'
        else
          content_tag :span, 'SUCCESS', class: 'label label-success'
        end
      else
        content_tag :span, 'FAILED', class: 'label label-danger'
      end
    when :pending
      content_tag :span, 'PENDING', class: 'label label-warning'
    when :failed
      content_tag :span, 'ERROR', class: 'label label-default'
    when :stopped
      content_tag :span, 'STOPPED', class: 'label label-default'
    end
  end

  def build_duration(build)
    case build.aasm_state.to_sym
    when :running
      'Running'
    when :pending
      'Pending'
    when :completed
      "Completed in #{build.duration_to_words}"
    when :failed
      'Error found when build'
    end
  end

  def build_time_ago(build)
    build.finished_at ? time_ago_in_words(build.finished_at) + ' ago' : 'Not finished yet'
  end
end
