module Semmy
  module Scm
    extend self

    def on_master?
      git.current_branch == 'master'
    end

    def on_stable?(stable_branch_name)
      !!git.current_branch.match(stable_branch_matcher(stable_branch_name))
    end

    private

    def stable_branch_matcher(stable_branch_name)
      Regexp.new(p(stable_branch_name.gsub(/%\{\w+\}/, '[0-9]+')))
    end

    def git
      Git.open('.')
    end
  end
end
