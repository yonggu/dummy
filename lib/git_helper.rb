module GitHelper
  def git_clone url, repository_path, commit_id, ssh_private_key_path = nil
    command = "git clone #{url} #{Shellwords.escape repository_path}"

    if ssh_private_key_path
      command = "ssh-add #{Shellwords.escape ssh_private_key_path}; " + command
      command = "ssh-agent bash -c '#{command}'"
    end

    command += " && cd #{Shellwords.escape repository_path} && git reset --hard #{commit_id}"

    run_command command
  end

  def git_reset repository_path, commit_id = 'HEAD'
    run_command "cd #{Shellwords.escape repository_path} && git reset --hard #{commit_id}"
  end

  def git_diff repository_path, path = nil
    run_command "cd #{Shellwords.escape repository_path} && git diff #{Shellwords.escape path}"
  end

  def git_checkout repository_path, options = {}
    command = "cd #{Shellwords.escape build.repository_path}"
    command += " && git checkout #{options[:base_branch]}"
    command += " && git reset #{options[:commit_id]} --hard"
    command += " && git checkout -b #{options[:source_branch]}" if options[:source_branch]

    run_command command
  end

  def git_push repository_path, options = {}
    command = "cd #{Shellwords.escape repository_path}"
    command += " && git add ."
    command += " && git commit -am '#{options[:commit_message]}'"
    command += " && git push origin #{options[:source_branch] || options[:base_branch]}"
    command += " && git checkout #{options[:base_branch]}"
    command += " && git reset #{options[:commit_id]} --hard"
    command += " && git branch -D #{options[:source_branch]}" if options[:source_branch]

    run_command command
  end

  private

  def run_command(command)
    begin
      result = `#{command}`
    rescue Exception => e
      Rollbar.error e, command: command
    end

    { result: result, success: $?.exitstatus == 0 }
  end
end
