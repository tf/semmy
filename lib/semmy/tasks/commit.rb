require 'git'

module Semmy
  module Tasks
    class Commit < Base
      def define
        namespace 'commit' do
          task 'prepare' do
            Shell.info('Creating prepare commit.')

            git.commit_all(config.prepare_commit_message % {
                             version: Project.version
                           })
          end

          task 'bump' do
            Shell.info('Creating bump commit.')

            git.commit_all(config.bump_commit_message % {
                             version: Project.version
                           })
          end
        end

        def git
          Git.open('.')
        end
      end
    end
  end
end
