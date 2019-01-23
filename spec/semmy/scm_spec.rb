require 'spec_helper'

module Semmy
  describe Scm, fixture_files: true do
    describe '.on_master?' do
      it 'returns true when on master branch' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')

        result = Scm.on_master?

        expect(result).to be(true)
      end

      it 'returns false when on other branch' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('other').checkout

        result = Scm.on_master?

        expect(result).to be(false)
      end
    end

    describe '.on_minor_version_stable?' do
      it 'returns true when current branch matches minor version stable branch name' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-0-stable').checkout

        result = Scm.on_minor_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(true)
      end

      it 'returns false when current branch is matches major version stable branch name' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-x-stable').checkout

        result = Scm.on_minor_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(false)
      end

      it 'returns false when on other branch' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('other').checkout

        result = Scm.on_minor_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(false)
      end
    end

    describe '.on_major_version_stable?' do
      it 'returns true when current branch matches major version stable branch name' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-x-stable').checkout

        result = Scm.on_major_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(true)
      end

      it 'returns false when current branch is matches minor version stable branch name' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('1-2-stable').checkout

        result = Scm.on_major_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(false)
      end

      it 'returns false when on other branch' do
        Fixtures.file('some', 'text')
        git = Fixtures.git_workspace
        git.add(all: true)
        git.commit('Initial commit')
        git.branch('other').checkout

        result = Scm.on_major_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(false)
      end
    end
  end
end
