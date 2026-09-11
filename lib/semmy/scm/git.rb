require 'git'

module Semmy
  module Scm
    module Git
      extend self

      def current_branch
        repository.current_branch
      end

      def commit_all(message, _branch)
        repository.commit_all(message)
      end

      def create_branch(name, _base)
        repository.branch(name).create
      end

      def push(remote, name)
        repository.push(remote, name)
      end

      def attach_git_head(_branch)
      end

      private

      def repository
        ::Git.open('.')
      end
    end
  end
end
