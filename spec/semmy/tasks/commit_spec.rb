require 'spec_helper'
require 'git'

module Semmy
  module Tasks
    describe Commit, fixture_files: true do
      describe 'prepare task' do
        it 'commits changes with prepare message' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Initial commit')

          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.5.0')

          Commit.new do |config|
            config.prepare_commit_message = 'Prepare %{version} release'
          end

          Rake.application['commit:prepare'].invoke
          commit = git.log.first

          expect(commit.message).to include('Prepare 1.5.0 release')
          expect(commit.gtree.blobs).to include('my_gem.gemspec')
        end
      end

      describe 'bump task' do
        it 'commits changes with bump message' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Fixtures.git_workspace
          git.add(all: true)
          git.commit('Initial commit')

          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.5.0.dev')

          Commit.new do |config|
            config.bump_commit_message = 'Bump version to %{version}'
          end

          Rake.application['commit:bump'].invoke
          commit = git.log.first

          expect(commit.message).to include('Bump version to 1.5.0.dev')
          expect(commit.gtree.blobs).to include('my_gem.gemspec')
        end
      end
    end
  end
end
