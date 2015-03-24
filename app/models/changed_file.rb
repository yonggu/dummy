class ChangedFile < ActiveRecord::Base
  belongs_to :build_item
  has_many :offenses, dependent: :destroy

  validates :path, presence: true

  def absolute_path
    Rails.root.join(build_item.build.repository_path, path).to_s
  end

  def diff_lines
    return [] if self.diff.blank?

    @diff_lines ||= Gitlab::Diff::Parser.new.parse(self.diff.lines)
  end

  def lines
    @lines = data.lines.map do |line|
      html_escape line.gsub(/\n/, '')
    end
  end

  def offense_line_numbers
    @offense_line_numbers ||= offenses.map(&:line)
  end

  private

  def data
    @data ||= File.read(self.absolute_path)
  end

  def html_escape(str)
    replacements = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;', "'" => '&#39;' }
    str.gsub(/[&"'><]/, replacements)
  end
end
