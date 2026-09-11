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
    describe '.release_branch' do
      it 'returns bookmark of jj working copy', jj: true do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Initial commit', bookmark: 'master')

        result = Scm.release_branch

        expect(result).to eq('master')
      end

      it 'keeps branch resolved before further bookmarks were created', jj: true do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
        Scm.release_branch
        Fixtures.jj_bookmark('1-4-stable', revision: 'master')

        result = Scm.release_branch

        expect(result).to eq('master')
      end

      it 'finds jj repository in parent directory', jj: true do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Initial commit', bookmark: 'master')
        FileUtils.mkdir_p('nested')

        result = Dir.chdir('nested') { Scm.release_branch }

        expect(result).to eq('master')
      end
    end

    context 'in jj repository', jj: true do
      it 'detects master bookmark' do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Initial commit', bookmark: 'master')

        result = Scm.on_master?

        expect(result).to be(true)
      end

      it 'detects stable bookmark' do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Initial commit', bookmark: '1-4-stable')

        result = Scm.on_minor_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(true)
      end

      it 'returns false when working copy has no bookmark' do
        Fixtures.jj_workspace
        Fixtures.file('some', 'text')
        Fixtures.jj_commit('Initial commit')

        result = Scm.on_major_version_stable?('%{major}-%{minor}-stable')

        expect(result).to be(false)
      end
    end
  end
end
