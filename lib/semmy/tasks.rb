require 'rake'

require 'semmy/tasks/base'
require 'semmy/tasks/branches'
require 'semmy/tasks/changelog_sections'
require 'semmy/tasks/commit'
require 'semmy/tasks/docs'
require 'semmy/tasks/versioning'

module Semmy
  module Tasks
    include Rake::DSL
    extend self

    def install
      config = Configuration.new
      yield config if block_given?

      namespace 'semmy' do
        Versioning.new(config)
        Docs.new(config)
        ChangelogSections.new(config)
        Commit.new(config)
        Branches.new(config)
      end

      desc 'Prepare minor or major release'
      task 'release:prepare:master' => [
        'semmy:versioning:remove_development_version_suffix',
        'semmy:docs:rewrite_since_tags',
        'semmy:changelog:close_section',
        'semmy:commit:prepare'
      ]

      desc 'Prepare patch level release'
      task 'release:prepare:stable' => [
        'semmy:changelog:close_section',
        'semmy:commit:prepare'
      ]

      desc 'Prepare release'
      task 'release:prepare' do
        if Scm.on_master?
          Rake.application['release:prepare:master'].invoke
        elsif Scm.on_stable?(config.stable_branch_name)
          Rake.application['release:prepare:stable'].invoke
        end
      end

      task 'release:after:master' => [
        'semmy:branches:create_stable',
        'semmy:versioning:bump_minor',
        'semmy:changelog:add_unreleased_section',
        'semmy:commit:bump'
      ]

      desc 'Prepare repository for development of next verion'
      task 'release:after' do
        if Scm.on_master?
          Rake.application['release:after:master'].invoke
        end
      end

      task 'release' do
        Rake.application['release:after'].invoke
      end
    end
  end
end
