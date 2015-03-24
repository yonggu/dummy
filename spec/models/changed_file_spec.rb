require 'rails_helper'

RSpec.describe ChangedFile, :type => :model do
  let(:project) { create(:github_project, name: 'dummy') }
  let(:build) { create(:build, last_commit_id: 'abcdefg', project: project) }
  let(:build_item) { create(:build_item, build: build) }
  let(:changed_file) { create(:changed_file, path: 'a/b/c.rb', build_item: build_item) }

  describe '#absolute_path' do
    it { expect(changed_file.absolute_path).to eq Rails.root.join('builds', 'repositories', 'dummy', 'abcdefg', 'a/b/c.rb').to_s }
  end

  describe '#diff_lines' do
    let(:diff) do
      <<eos
--- a/files/ruby/popen.rb
+++ b/files/ruby/popen.rb
@@ -6,12 +6,18 @@ module Popen

   def popen(cmd, path=nil)
     unless cmd.is_a?(Array)
-      raise "System commands must be given as an array of strings"
+      raise RuntimeError, "System commands must be given as an array of strings"
     end

     path ||= Dir.pwd
-    vars = { "PWD" => path }
-    options = { chdir: path }
+
+    vars = {
+      "PWD" => path
+    }
+
+    options = {
+      chdir: path
+    }

     unless File.directory?(path)
       FileUtils.mkdir_p(path)
@@ -19,6 +25,7 @@ module Popen

     @cmd_output = ""
     @cmd_status = 0
+
     Open3.popen3(vars, *cmd, options) do |stdin, stdout, stderr, wait_thr|
       @cmd_output << stdout.read
       @cmd_output << stderr.read
eos
    end

    let(:changed_file) { create(:changed_file, path: 'a/b/c.rb', diff: diff, build_item: build_item) }

    it { expect(changed_file.diff_lines.map(&:old_pos)).to eq [6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16, 17, 19, 19, 20, 21, 22, 22, 23, 24] }
    it { expect(changed_file.diff_lines.map(&:new_pos)).to eq [6, 6, 7, 8, 9, 9, 10, 11, 12, 13, 13, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 25, 26, 27, 28, 29, 30, 31] }
  end

  describe "#offense_line_numbers" do
    before do
      create :offense, changed_file: changed_file, line: 5
      create :offense, changed_file: changed_file, line: 20
    end

    it { expect(changed_file.offense_line_numbers).to eq [5, 20] }
  end

  describe "#lines" do
    before do
      changed_file.path = "demo.rb"
      changed_file.save

      allow(changed_file).to receive(:absolute_path) { Rails.root.join("spec", "fixtures", "demo.rb") }
    end

    it { expect(changed_file.lines).to eq (["class Demo", "  def run", "    p &quot;run&quot;", "  end", "end"]) }
  end
end
