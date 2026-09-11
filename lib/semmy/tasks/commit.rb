module Semmy
  module Tasks
    class Commit < Base
      def define
        namespace 'commit' do
          task 'prepare' do
            Shell.info('Creating prepare commit.')

            Scm.commit_all(config.prepare_commit_message % {
                             version: Project.version
                           })
          end

          task 'bump' do
            Shell.info('Creating bump commit.')

            Scm.commit_all(config.bump_commit_message % {
                             version: Project.version
                           })
          end
        end
      end
    end
  end
end
