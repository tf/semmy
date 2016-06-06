require 'spec_helper'
require 'git'

module Semmy
  module Tasks
    describe Branches, fixture_files: true do
      describe 'create_stable task' do
        it 'creates stable branch' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          git = Git.init
          git.add(all: true)
          git.commit('Prepare 1.4.0 release')

          Branches.new do |config|
            config.stable_branch_name = '%{major}-%{minor}-stable'
          end

          Rake.application['branches:create_stable'].invoke

          expect(git.branches['1-4-stable']).not_to be_nil
        end
      end
    end
  end
end
