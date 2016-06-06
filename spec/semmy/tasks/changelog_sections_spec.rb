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

            ## Changes on master
          END

          ChangelogSections.new do |config|
            config.changelog_unrelased_section_heading = '## Changes on master'
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

            ## Changes on master
          END

          ChangelogSections.new do |config|
            config.changelog_unrelased_section_heading = '## Changes on master'
          end

          Rake.application['changelog:close_section'].invoke

          compare_url = 'https://github.com/me/my_gem/compare/v1.3.0..v1.4.0'
          expect(changelog.read).to include(compare_url)
        end
      end
    end
  end
end
