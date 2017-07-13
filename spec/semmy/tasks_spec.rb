require 'spec_helper'

module Semmy
  describe Tasks, fixture_files: true do
    describe 'release:prepare task' do
      it 'passes on master' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '1.5.0.dev')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Unreleased Changes
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')

        Tasks.install

        expect {
          Rake.application['release:prepare'].invoke
        }.not_to raise_error
      end

      it 'passes on stable branch' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '1.5.2')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Unreleased Changes
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-5-stable').checkout

        Tasks.install

        expect {
          Rake.application['release:prepare'].invoke
        }.not_to raise_error
      end
    end

    describe 'release:after task invoked after release task' do
      it 'passes on master' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '1.5.0')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Version 1.5.0
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Prepare 1.5 release')

        Tasks.install

        expect {
          Rake.application['release'].invoke
        }.not_to raise_error
      end
    end

    describe 'begin_patch_level' do
      it 'passes on stable branch' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '1.5.2')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Version 1.5.2
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-5-stable').checkout

        Tasks.install

        expect {
          Rake.application['begin_patch_level'].invoke
        }.not_to raise_error
      end
    end
  end
end
