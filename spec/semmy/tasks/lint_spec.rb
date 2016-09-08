require 'spec_helper'

module Semmy
  module Tasks
    describe Lint, fixture_files: true do
      describe 'install task' do
        it 'passes if gem can be built and installed' do
          Fixtures.gemspec(name: 'semmy_test_gem', module: 'SemmyTestGem')
          Fixtures.version_file('lib/semmy_test_gem/version.rb',
                                module: 'SemmyTestGem',
                                version: '1.4.0.dev')
          Lint.new

          expect {
            Rake.application['lint:install'].invoke
          }.not_to raise_error
        end

        it 'fails if gem has unsatisfied dependency' do
          Fixtures.gemspec(name: 'semmy_test_gem',
                           module: 'SemmyTestGem',
                           dependency: 'a_gem_that_will_hopefully_never_exist')
          Fixtures.version_file('lib/semmy_test_gem/version.rb',
                                module: 'SemmyTestGem',
                                version: '1.4.0')
          Lint.new

          expect {
            Rake.application['lint:install'].invoke
          }.to raise_error(SystemExit)
        end
      end

      describe 'locales task' do
        it 'returns false if no config/locales/new/ direcotry is present' do
          Lint.new

          expect {
            Rake.application['lint:locales'].invoke
          }.not_to raise_error
        end

        it 'returns true if config/locales/new/ files are present' do
          Fixtures.file('config/locales/new/some.yml')

          Lint.new

          expect {
            Rake.application['lint:locales'].invoke
          }.to raise_error(SystemExit)
        end
      end
    end
  end
end
