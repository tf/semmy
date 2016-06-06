require 'git'

module Semmy
  module Tasks
    Docs = Struct.new(:config) do
      include Rake::DSL

      def initialize
        config ||= Configuration.new

        yield(config)

        namespace 'docs' do
          task 'rewrite_since_tags' do
            Files.rewrite_all(config.source_files_with_docs_tags,
                              DocTags::UpdateSinceTags.new(config.rewritten_since_doc_tag,
                                                           Gemspec.version))
          end
        end
      end
    end
  end
end
