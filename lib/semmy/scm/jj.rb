require 'open3'

module Semmy
  module Scm
    module Jj
      extend self

      class CommandFailed < Error; end
      class BookmarkNotFound < Error; end

      def current_branch
        jj('log', '--no-graph',
           '--revisions', 'heads(::@ & bookmarks())',
           '--template', 'local_bookmarks.map(|bookmark| bookmark.name()).join("\n")')
          .split("\n").first
      end

      def commit_all(message, branch)
        bookmark = required_bookmark(branch)

        jj('commit', '--message', message)
        jj('bookmark', 'set', bookmark, '--revision', '@-')
      end

      def create_branch(name, base)
        jj('bookmark', 'create', name, '--revision', required_bookmark(base))
      end

      def push(remote, name)
        unless bookmark?(name)
          fail(BookmarkNotFound, "Bookmark #{name} does not exist.")
        end

        jj('git', 'push', '--remote', remote, '--bookmark', name)
      end

      private

      def required_bookmark(name)
        name ||
          fail(BookmarkNotFound,
               'No bookmark found in ancestors of working copy commit.')
      end

      def bookmark?(name)
        !jj('bookmark', 'list', '--template', 'name ++ "\n"', name).strip.empty?
      end

      def jj(*args)
        stdout, stderr, status = Open3.capture3('jj', *args)

        unless status.success?
          fail(CommandFailed, "Command `jj #{args.join(' ')}` failed:\n#{stderr}")
        end

        Shell.sub_process_output(stderr.chomp) unless stderr.empty?
        stdout
      end
    end
  end
end
