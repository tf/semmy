require 'git'

module Semmy
  module Tasks
    class Branches < Base
      def define
        namespace 'branches' do
          task 'create_stable' do
            name = config.stable_branch_name %
              VersionString.components(Project.version)

            Shell.info("Creating stable branch #{name}.")

            git.branch(name).create
          end
        end

        def git
          Git.open('.')
        end
      end
    end
  end
end
