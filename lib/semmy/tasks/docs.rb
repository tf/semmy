require 'git'

module Semmy
  module Tasks
    class Docs < Base
      def define
        namespace 'docs' do
          task 'rewrite_since_tags' do
            Files.rewrite_all(config.source_files_with_docs_tags,
                              DocTags::UpdateSinceTags.new(config.rewritten_since_doc_tag,
                                                           Project.version))
          end
        end
      end
    end
  end
end
