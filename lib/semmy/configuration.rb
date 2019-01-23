module Semmy
  class Configuration
    attr_accessor :development_version_suffix

    attr_accessor :stable_branch_name
    attr_accessor :push_branches_after_release

    attr_accessor :prepare_commit_message
    attr_accessor :bump_commit_message

    attr_accessor :github_repository

    attr_accessor :compare_url
    attr_accessor :file_url

    attr_accessor :changelog_path
    attr_accessor :changelog_version_section_heading
    attr_accessor :changelog_unreleased_section_heading
    attr_accessor :changelog_unreleased_section_blank_slate
    attr_accessor :changelog_previous_changes_link

    attr_accessor :source_files_with_docs_tags
    attr_accessor :rewritten_since_doc_tag

    def initialize
      @development_version_suffix = 'dev'

      @stable_branch_name = '%{major}-%{minor}-stable'
      @push_branches_after_release = ENV['SEMMY_PUSH_BRANCHES_AFTER_RELEASE'] == 'on'

      @prepare_commit_message = 'Prepare %{version} release'
      @bump_commit_message = 'Bump version to %{version}'

      @compare_url = '%{repository}/compare/%{old_version_tag}...%{new_version_tag}'
      @file_url = '%{repository}/blob/%{branch}/%{path}'

      @changelog_path = 'CHANGELOG.md'
      @changelog_version_section_heading = '### Version %{version}'
      @changelog_unreleased_section_heading = '### Unreleased Changes'
      @changelog_unreleased_section_blank_slate = 'None so far.'
      @changelog_previous_changes_link = "See\n[%{branch} branch](%{url})\nfor previous changes."

      @source_files_with_docs_tags = '{app,lib}/**/*.{js,rb,scss}'
      @rewritten_since_doc_tag = 'edge'

      yield self if block_given?
    end
  end
end
