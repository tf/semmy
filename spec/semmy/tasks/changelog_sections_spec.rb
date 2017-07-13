require 'spec_helper'

module Semmy
  module Tasks
    describe Changelog, fixture_files: true do
      describe 'close_section task' do
        it 'inserts version heading' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          changelog = Fixtures.file('CHANGELOG.md', <<-END)
            # Changelog

            ## Unreleased Changes
          END

          ChangelogSections.new do |config|
            config.changelog_unreleased_section_heading = '## Unreleased Changes'
          end

          Rake.application['changelog:close_section'].invoke

          expect(changelog.read).to include('## Version 1.4.0')
        end

        it 'derives compare url from homepage' do
          Fixtures.gemspec(name: 'my_gem',
                           module: 'MyGem',
                           homepage: 'https://github.com/me/my_gem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          changelog = Fixtures.file('CHANGELOG.md', <<-END)
            # Changelog

            ## Unreleased Changes
          END

          ChangelogSections.new do |config|
            config.changelog_unreleased_section_heading = '## Unreleased Changes'
            config.stable_branch_name = '%{major}-%{minor}-stable'
          end

          Rake.application['changelog:close_section'].invoke

          compare_url = 'https://github.com/me/my_gem/compare/1-3-stable...v1.4.0'
          expect(changelog.read).to include(compare_url)
        end

        it 'prefers github repository url for compare link' do
          Fixtures.gemspec(name: 'my_gem',
                           module: 'MyGem',
                           homepage: 'https://my-gem.org')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          changelog = Fixtures.file('CHANGELOG.md', <<-END)
            # Changelog

            ## Unreleased Changes
          END

          ChangelogSections.new do |config|
            config.changelog_unreleased_section_heading = '## Unreleased Changes'
            config.github_repository = 'me/my_gem'
            config.stable_branch_name = '%{major}-%{minor}-stable'
          end

          Rake.application['changelog:close_section'].invoke

          compare_url = 'https://github.com/me/my_gem/compare/1-3-stable...v1.4.0'
          expect(changelog.read).to include(compare_url)
        end
      end

      describe 'update_for_minor task' do
        before do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '2.3.0.dev')

          ChangelogSections.new do |config|
            config.changelog_version_section_heading = '## Version %{version}'
            config.changelog_unreleased_section_heading = '## Unreleased Changes'
          end
        end

        let!(:changelog) do
          Fixtures.file('CHANGELOG.md', <<-END)
            # Changelog

            ## Version 2.2.0
          END
        end

        it 'inserts unreleased changes section' do
          Rake.application['changelog:update_for_minor'].invoke

          expect(changelog.read).to include('## Unreleased Changes')
        end

        it 'removes previous version section' do
          Rake.application['changelog:update_for_minor'].invoke

          expect(changelog.read).not_to include('## Version 2.2.0')
        end
      end
    end
  end
end
