require 'git'

module Semmy
  module Tasks
    class Lint < Base
      def define
        task 'lint' => ['lint:install', 'lint:locales']

        namespace 'lint' do
          task 'install' do
            Shell.info('Ensuring gem can be installed.')

            unless RubyGems.build_and_test_install
              Shell.error('Test install failed.')
              exit(1)
            end
          end

          task 'locales' do
            Shell.info('Checking for not yet imported locales.')

            if Project.has_not_yet_imported_locales?
              Shell.error('There are still files in config/locales/new.')
              exit(1)
            end
          end
        end
      end
    end
  end
end
