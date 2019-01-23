require 'spec_helper'

module Semmy
  module Tasks
    describe Branches, fixture_files: true do
      describe 'create_stable task' do
        it 'creates stable branch' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')

          Branches.new do |config|
            config.stable_branch_name = '%{major}-%{minor}-stable'
          end

          Rake.application['branches:create_stable'].invoke

          expect(git.branches['1-4-stable']).not_to be_nil
        end

        it 'stays on master' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')

          Branches.new do |config|
            config.stable_branch_name = '%{major}-%{minor}-stable'
          end

          Rake.application['branches:create_stable'].invoke

          expect(git.current_branch).to eq('master')
        end
      end

      describe 'push_master task' do
        it 'pushes master branch to default origin' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')
          remote_repository = Fixtures.git_remote_repository('origin')

          Branches.new

          Rake.application['branches:push_master'].invoke
          local_master = git.branches[:master].gcommit
          remote_master = remote_repository.branches[:master].gcommit

          expect(remote_master.sha).to eq(local_master.sha)
        end

        it 'supports pushing to custom remote' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')
          remote_repository = Fixtures.git_remote_repository('upstream')

          Branches.new

          Rake.application['branches:push_master'].invoke('upstream')
          local_master = git.branches[:master].gcommit
          remote_master = remote_repository.branches[:master].gcommit

          expect(remote_master.sha).to eq(local_master.sha)
        end
      end

      describe 'push_previous_stable task' do
        it 'pushes previous stable branch to default origin' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')
          git.branch('1-4-stable').create
          remote_repository = Fixtures.git_remote_repository('origin')

          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.5.0')
          git.add(all: true)
          git.commit('Bump verion to 1.5.0')

          Branches.new

          Rake.application['branches:push_previous_stable'].invoke
          local_master = git.branches['1-4-stable'].gcommit
          remote_master = remote_repository.branches['1-4-stable'].gcommit

          expect(remote_master.sha).to eq(local_master.sha)
        end

        it 'supports pushing to custom remote' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')
          git.branch('1-4-stable').create
          remote_repository = Fixtures.git_remote_repository('upstream')

          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.5.0')
          git.add(all: true)
          git.commit('Bump verion to 1.5.0')

          Branches.new

          Rake.application['branches:push_previous_stable'].invoke('upstream')
          local_master = git.branches['1-4-stable'].gcommit
          remote_master = remote_repository.branches['1-4-stable'].gcommit

          expect(remote_master.sha).to eq(local_master.sha)
        end
      end

      it 'pushing can be disabled' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '1.4.0')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Prepare 1.4.0 release')
        remote_repository = Fixtures.git_remote_repository('origin')

        Branches.new do |config|
          config.push_branches_after_release = false
        end

        Rake.application['branches:push_master'].invoke
        remote_master = remote_repository.branches[:master]

        expect(remote_master).to eq(nil)
      end
    end
  end
end
