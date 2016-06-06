require 'git'

module Semmy
  module Tasks
    Branches = Struct.new(:config) do
      include Rake::DSL

      def initialize
        config ||= Configuration.new

        yield(config)

        namespace 'branches' do
          task 'create_stable' do
            name = config.stable_branch_name %
              VersionString.components(Gemspec.version)

            git.branch(name).checkout
          end
        end

        def git
          Git.open('.')
        end
      end
    end
  end
end
