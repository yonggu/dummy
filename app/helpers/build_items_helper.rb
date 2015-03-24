module BuildItemsHelper
  def build_item_state_tag(build_item)
    if build_item.passed?
      content_tag :span, 'Success', class: 'label label-success'
    elsif build_item.already_push_directly?
      content_tag :span, 'Already pushed directly', class: 'label label-info'
    elsif build_item.already_pull_request?
      content_tag :span, 'Already sent a pull request', class: 'label label-info'
    else
      content_tag :span, 'Failure', class: 'label label-danger'
    end
  end
end
