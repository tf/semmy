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

        expect(git.log.first.message).to match(/Prepare/)
      end

      it 'passes on major version stable branch master' do
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
        git.commit('Some commit')
        git.branch('1-x-stable').checkout

        Tasks.install

        expect {
          Rake.application['release:prepare'].invoke
        }.not_to raise_error

        expect(git.log.first.message).to match(/Prepare/)
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

      it 'passes on master for major version' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '2.0.0.dev')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Unreleased Changes
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Some commit')

        Tasks.install

        expect {
          Rake.application['release:prepare'].invoke
        }.not_to raise_error

        expect(git.log.first.message).to match(/Prepare/)
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
        Fixtures.git_remote_repository('upstream')

        Tasks.install

        expect {
          Rake.application['release'].invoke('upstream')
        }.not_to raise_error

        expect(git.log.first.message).to match(/Bump/)
      end

      it 'passes on master for major version' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '2.0.0')
        Fixtures.file('CHANGELOG.md', <<-END)
          # Changelog

          ### Version 2.0.0
        END

        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Prepare 2.0 release')
        Fixtures.git_remote_repository('origin')

        Tasks.install

        expect {
          Rake.application['release'].invoke
        }.not_to raise_error

        expect(git.log.first.message).to match(/Bump/)
      end

      it 'passes on major version stable branch' do
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
        git.branch('1-x-stable').checkout
        Fixtures.git_remote_repository('origin')

        Tasks.install

        expect {
          Rake.application['release'].invoke
        }.not_to raise_error

        expect(git.log.first.message).to match(/Bump/)
      end
    end

    describe 'bump:patch' do
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
          Rake.application['bump:patch'].invoke
        }.not_to raise_error
      end
    end

    describe 'bump:major' do
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
        git.branch('master').checkout

        Tasks.install

        expect {
          Rake.application['bump:major'].invoke
        }.not_to raise_error
      end
    end
  end
end
