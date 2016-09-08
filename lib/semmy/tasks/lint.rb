require 'git'

module Semmy
  module Tasks
    class Lint < Base
      def define
        task 'lint' => ['lint:install']

        namespace 'lint' do
          task 'install' do
            Shell.info('Ensuring gem can be installed.')

            unless RubyGems.build_and_test_install
              Shell.error('Test install failed.')
              exit(1)
            end
          end
        end
      end
    end
  end
end
