module Semmy
  module Scm
    extend self

    def on_master?
      git.current_branch == 'master'
    end

    def on_minor_version_stable?(stable_branch_name)
      !!git.current_branch.match(stable_branch_matcher(stable_branch_name))
    end

    def on_major_version_stable?(stable_branch_name)
      !!git.current_branch.match(major_version_stable_branch_matcher(stable_branch_name))
    end

    private

    def major_version_stable_branch_matcher(stable_branch_name)
      stable_branch_matcher(stable_branch_name.gsub('%{minor}', 'x'))
    end

    def stable_branch_matcher(stable_branch_name)
      Regexp.new(stable_branch_name.gsub(/%\{\w+\}/, '[0-9]+'))
    end

    def git
      Git.open('.')
    end
  end
end
