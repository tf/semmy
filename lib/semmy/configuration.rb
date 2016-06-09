module Semmy
  class Configuration
    attr_accessor :development_version_suffix

    attr_accessor :stable_branch_name

    attr_accessor :prepare_commit_message
    attr_accessor :bump_commit_message

    attr_accessor :github_repository

    attr_accessor :changelog_path
    attr_accessor :changelog_version_section_heading
    attr_accessor :changelog_compare_url
    attr_accessor :changelog_unrelased_section_heading
    attr_accessor :changelog_unrelased_section_blank_slate

    attr_accessor :source_files_with_docs_tags
    attr_accessor :rewritten_since_doc_tag

    def initialize
      @development_version_suffix = 'dev'

      @stable_branch_name = '%{major}-%{minor}-stable'

      @prepare_commit_message = 'Prepare %{version} release'
      @bump_commit_message = 'Bump version to %{version}'

      @changelog_path = 'CHANGELOG.md'
      @changelog_version_section_heading = '### Version %{version}'
      @changelog_compare_url = '%{repository}/compare/%{old_version_tag}...%{new_version_tag}'
      @changelog_unrelased_section_heading = '### Changes on `master`'
      @changelog_unrelased_section_blank_slate = 'None so far.'

      @source_files_with_docs_tags = '{app,lib}/**/*.{js,rb,scss}'
      @rewritten_since_doc_tag = 'edge'

      yield self if block_given?
    end
  end
end
