require 'git'

module Semmy
  module Tasks
    Commit = Struct.new(:config) do
      include Rake::DSL

      def initialize
        config ||= Configuration.new

        yield(config)

        namespace 'commit' do
          task 'prepare' do
            git.commit_all(config.prepare_commit_message % {
                             version: Gemspec.version
                           })
          end

          task 'bump' do
            git.commit_all(config.bump_commit_message % {
                             version: Gemspec.version
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
