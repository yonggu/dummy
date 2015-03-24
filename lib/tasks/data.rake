namespace :data do
  namespace :project do
    task :create_aasm_state => :environment do
      Project.where(aasm_state: nil).each do |project|
        if project.builds.count > 0
          project.update_attribute :aasm_state, :active
        else
          project.update_attribute :aasm_state, :inactive
        end
      end
    end
  end
end
