require 'rake'

require 'semmy/tasks/changelog_sections'
require 'semmy/tasks/versioning'

module Semmy
  module Tasks
    include Rake::DSL

    def define
      config = Configuration.new
      yield configuration if block_given?

      namespace 'semmy' do
        Versioning.new(config)
        Docs.new(config)
        ChangelogSections.new(config)
        Commit.new(config)
        Branches.new(config)
      end

      task 'release:prepare' => [
        'semmy:versioning:remove_dev_suffix',
        'semmy:docs:rewrite_since_tags',
        'semmy:changelog:close_section',
        'semmy:commit:prepare'
      ]

      task 'release:after' => [
        'semmy:branches:create_stable',
        'semmy:versioning:bump_minor',
        'semmy:changelog:add_unreleased_section',
        'semmy:commit:dev'
      ]
    end
  end
end
