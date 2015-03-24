module Emails
  module Builds
    def build_finished_email(build_id)
      @build = Build.find build_id

      @emails = @build.project.users.map(&:email).compact
      @previous_build = @build.project.previous_build

      mail from: 'Awesome Code Build <notification@awesomecode.io>',
           to: @emails,
           subject: 'Build notification'
    end

    private

    def duration_to_words
    end
  end
end
