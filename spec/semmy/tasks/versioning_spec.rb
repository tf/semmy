require 'spec_helper'

module Semmy
  module Tasks
    describe Versioning, fixture_files: true do
      describe 'remove_development_version_suffix task' do
        it 'removes development suffix from version in version file' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          version_file = Fixtures.version_file('lib/my_gem/version.rb',
                                               module: 'MyGem',
                                               version: '1.4.0.dev')
          Versioning.new do |config|
            config.development_version_suffix = 'dev'
          end

          Rake.application['versioning:remove_development_version_suffix'].invoke

          expect(version_file.read).to match(/VERSION = '1.4.0'/)
        end
      end

      describe 'bump_minor task' do
        it 'bumps minor and appends development version suffix' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          version_file = Fixtures.version_file('lib/my_gem/version.rb',
                                               module: 'MyGem',
                                               version: '1.2.0')

          Versioning.new do |config|
            config.development_version_suffix = 'dev'
          end

          Rake.application['versioning:bump_minor'].invoke

          expect(version_file.read).to match(/VERSION = '1.3.0.dev'/)
        end
      end

      describe 'bump_patch_level task' do
        it 'bumps patch level version' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          version_file = Fixtures.version_file('lib/my_gem/version.rb',
                                               module: 'MyGem',
                                               version: '1.2.3')

          Versioning.new

          Rake.application['versioning:bump_patch_level'].invoke

          expect(version_file.read).to match(/VERSION = '1.2.4'/)
        end
      end
    end
  end
end
