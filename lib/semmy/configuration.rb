module Semmy
  class Configuration
    attr_accessor :development_version_suffix

    attr_accessor :stable_branch_name

    attr_accessor :prepare_commit_message
    attr_accessor :bump_commit_message

    attr_accessor :changelog_path
    attr_accessor :changelog_section_heading
    attr_accessor :changelog_unrelased_section_heading

    attr_accessor :rewritten_since_doc_tag

    def initialize
      @development_version_suffix = 'dev'

      @stable_branch_name = '%{major}-%{minor}-stable'

      @prepare_commit_message = 'Prepare %{version} Release'
      @bump_commit_message = 'Bump Version to %{version}'

      @changelog_path = 'CHANGELOG.md'
      @changelog_section_heading = '## Version %{version}'
      @changelog_unrelased_section_heading = '## Changes on `master`'

      @rewritten_since_doc_tag = 'edge'
    end
  end
end
