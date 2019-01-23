require 'git'

module Semmy
  module Tasks
    class Branches < Base
      def define
        namespace 'branches' do
          task 'create_stable' do
            Shell.info("Creating stable branch #{stable_branch_name}.")

            git.branch(stable_branch_name).create
          end

          task 'push_master', [:remote] do |_, args|
            push_branch(args[:remote], 'master')
          end

          task 'push_previous_stable', [:remote] do |_, args|
            push_branch(args[:remote], previous_stable_branch_name)
          end
        end
      end

      private

      def stable_branch_name
        VersionString.stable_branch_name(Project.version,
                                         config.stable_branch_name)
      end

      def previous_stable_branch_name
        VersionString.previous_stable_branch_name(Project.version,
                                                  config.stable_branch_name)
      end

      def push_branch(remote, name)
        remote ||= 'origin'

        if config.push_branches_after_release
          Shell.info("Pushing #{name} to #{remote}.")
          git.push(remote, name)
        else
          Shell.info("NOTE: Remember to push #{name} to #{remote}.")
        end
      end

      def git
        Git.open('.')
      end
    end
  end
end
