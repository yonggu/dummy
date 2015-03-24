module ProjectsHelper
  def project_icon(project)
    if project.is_a? GithubProject
      image_tag 'github-24-black.png', class: 'project-icon'
    elsif project.is_a? BitbucketProject
      image_tag 'bitbucket-24-black.png', class: 'project-icon'
    else
      # no icon
    end
  end

  def render_projects_analysis_config_item_field(projects_analysis_config_item)
    analysis_config_item = projects_analysis_config_item.analysis_config_item
    name = "projects_analysis_config[projects_analysis_config_items_attributes][#{projects_analysis_config_item.id}][value]"
    if analysis_config_item.options.present?
      select_tag name, options_for_select(analysis_config_item.options, projects_analysis_config_item.value)
    else
      case analysis_config_item.value
      when String, Fixnum, Regexp
        text_field_tag name, projects_analysis_config_item.value, class: 'form-control'
      when Array
        text_field_tag name, projects_analysis_config_item.value.join(","), class: 'form-control', 'data-role' => 'tagsinput'
      when TrueClass, FalseClass
        content_tag(:label, class: 'radio-inline') do
          concat radio_button_tag name, true, projects_analysis_config_item.value
          concat 'Yes'
        end + content_tag(:label, class: 'radio-inline') do
          concat radio_button_tag name, false, !projects_analysis_config_item.value
          concat 'No'
        end
      else
        text_area_tag name, projects_analysis_config_item.value, class: 'form-control'
      end
    end
  end

  def project_status_markdown(project)
    "[ ![AwesomeCode Status for #{project.name}](#{status_project_url(project)})](#{project_url(project)})"
  end

  def project_status_textile(project)
    "&quot;!#{status_project_url(project)}!&quot;:#{project_url(project)}"
  end

  def project_status_rdoc(project)
    "{<img alt=&quot;AwesomeCode Status&quot; src=&quot;#{status_project_url(project)}&quot; />}[#{project_url(project)}]"
  end
end
