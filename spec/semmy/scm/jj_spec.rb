require 'spec_helper'

module Semmy
  module Scm
    describe Jj, fixture_files: true, jj: true do
      describe '.current_branch' do
        it 'returns bookmark pointing at working copy parent' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit', bookmark: 'master')

          result = Jj.current_branch

          expect(result).to eq('master')
        end

        it 'returns closest bookmark in ancestors' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit', bookmark: '1-4-stable')
          Fixtures.file('other', 'text')
          Fixtures.jj_commit('Commit without bookmark')

          result = Jj.current_branch

          expect(result).to eq('1-4-stable')
        end

        it 'returns name without sync marker for bookmark ahead of remote' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit', bookmark: 'master')
          Fixtures.git_remote_repository('origin')
          Jj.push('origin', 'master')
          Fixtures.file('other', 'text')
          Fixtures.jj_commit('Second commit', bookmark: 'master')

          result = Jj.current_branch

          expect(result).to eq('master')
        end

        it 'returns nil when no bookmark in ancestors' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit')

          result = Jj.current_branch

          expect(result).to be_nil
        end
      end

      describe '.commit_all' do
        it 'commits working copy changes with message' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit', bookmark: 'master')
          Fixtures.file('other', 'text')

          Jj.commit_all('Prepare 1.4.0 release', 'master')

          expect(Fixtures.jj_description('@-')).to eq('Prepare 1.4.0 release')
        end

        it 'moves given bookmark to new commit' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit', bookmark: 'master')
          Fixtures.file('other', 'text')

          Jj.commit_all('Prepare 1.4.0 release', 'master')

          expect(Fixtures.jj_commit_id('master')).to eq(Fixtures.jj_commit_id('@-'))
        end

        it 'leaves other bookmarks at same commit in place' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
          Fixtures.jj_bookmark('1-4-stable', revision: 'master')
          Fixtures.file('other', 'text')

          Jj.commit_all('Bump version to 1.5.0.dev', 'master')

          expect(Fixtures.jj_description('1-4-stable')).to eq('Prepare 1.4.0 release')
        end

        it 'fails without bookmark' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit')
          Fixtures.file('other', 'text')

          expect { Jj.commit_all('Prepare 1.4.0 release', nil) }
            .to raise_error(Jj::BookmarkNotFound)
        end
      end

      describe '.create_branch' do
        it 'creates bookmark at given base' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')

          Jj.create_branch('1-4-stable', 'master')

          expect(Fixtures.jj_commit_id('1-4-stable'))
            .to eq(Fixtures.jj_commit_id('master'))
        end

        it 'ignores commits made after given base' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
          Fixtures.file('other', 'text')
          Fixtures.jj_commit('Commit without bookmark')

          Jj.create_branch('1-4-stable', 'master')

          expect(Fixtures.jj_description('1-4-stable')).to eq('Prepare 1.4.0 release')
        end

        it 'fails without base' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Initial commit')

          expect { Jj.create_branch('1-4-stable', nil) }
            .to raise_error(Jj::BookmarkNotFound)
        end
      end

      describe '.push' do
        it 'pushes bookmark to remote' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
          remote_repository = Fixtures.git_remote_repository('origin')

          Jj.push('origin', 'master')

          expect(remote_repository.branches[:master].gcommit.sha)
            .to eq(Fixtures.jj_commit_id('master'))
        end

        it 'supports pushing to custom remote' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
          remote_repository = Fixtures.git_remote_repository('upstream')

          Jj.push('upstream', 'master')

          expect(remote_repository.branches[:master].gcommit.sha)
            .to eq(Fixtures.jj_commit_id('master'))
        end

        it 'fails when bookmark does not exist' do
          Fixtures.jj_workspace
          Fixtures.file('some', 'text')
          Fixtures.jj_commit('Prepare 1.4.0 release', bookmark: 'master')
          Fixtures.git_remote_repository('origin')

          expect { Jj.push('origin', '1-4-stable') }
            .to raise_error(Jj::BookmarkNotFound)
        end
      end
    end
  end
end
