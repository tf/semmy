require 'pathname'

require 'semmy/scm/git'
require 'semmy/scm/jj'

module Semmy
  module Scm
    extend self

    def on_master?
      release_branch == 'master'
    end

    def on_minor_version_stable?(stable_branch_name)
      !!release_branch.to_s.match(stable_branch_matcher(stable_branch_name))
    end

    def on_major_version_stable?(stable_branch_name)
      !!release_branch.to_s.match(major_version_stable_branch_matcher(stable_branch_name))
    end

    def commit_all(message)
      repository.commit_all(message, release_branch)
    end

    def create_branch(name)
      repository.create_branch(name, release_branch)
    end

    def push(remote, name)
      repository.push(remote, name)
    end

    def attach_git_head
      repository.attach_git_head(release_branch)
    end

    def release_branch
      @release_branch ||= repository.current_branch
    end

    def reset
      @release_branch = nil
    end

    private

    def major_version_stable_branch_matcher(stable_branch_name)
      stable_branch_matcher(stable_branch_name.gsub('%{minor}', 'x'))
    end

    def stable_branch_matcher(stable_branch_name)
      Regexp.new(stable_branch_name.gsub(/%\{\w+\}/, '[0-9]+'))
    end

    def repository
      Pathname.pwd.ascend do |directory|
        return Jj if directory.join('.jj').directory?
        return Git if directory.join('.git').exist?
      end

      Git
    end
  end
end
