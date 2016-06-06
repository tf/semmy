require 'spec_helper'

module Semmy
  module Tasks
    describe Docs, fixture_files: true do
      describe 'rewrite_since_tags task' do
        it 'inserts versions into since tags' do
          Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
          Fixtures.version_file('lib/my_gem/version.rb',
                                module: 'MyGem',
                                version: '1.4.0')
          file = Fixtures.file('lib/my_gem.rb', <<-END)
            module MyGem
              # @since edge
              def new_method
              end
            end
          END

          Docs.new do |config|
            config.source_files_with_docs_tags = '{lib,app}/**/*.rb'
            config.rewritten_since_doc_tag = 'edge'
          end

          Rake.application['docs:rewrite_since_tags'].invoke

          expect(file.read).to include('# @since 1.4')
        end
      end
    end
  end
end
