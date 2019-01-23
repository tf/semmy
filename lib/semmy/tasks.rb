require 'rake'

require 'semmy/tasks/base'
require 'semmy/tasks/branches'
require 'semmy/tasks/changelog_sections'
require 'semmy/tasks/commit'
require 'semmy/tasks/docs'
require 'semmy/tasks/lint'
require 'semmy/tasks/versioning'

module Semmy
  module Tasks
    include Rake::DSL
    extend self

    def install
      config = Configuration.new
      yield config if block_given?

      namespace 'semmy' do
        Lint.new(config)
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
      task 'release:prepare' => 'semmy:lint' do
        if Scm.on_master? || Scm.on_major_version_stable?(config.stable_branch_name)
          Rake.application['release:prepare:master'].invoke
        elsif Scm.on_minor_version_stable?(config.stable_branch_name)
          Rake.application['release:prepare:stable'].invoke
        end
      end

      task 'release:after:master', [:remote] => [
        'semmy:branches:create_stable',
        'semmy:versioning:bump_minor',
        'semmy:changelog:update_for_minor',
        'semmy:commit:bump',
        'semmy:branches:push_master',
        'semmy:branches:push_previous_stable'
      ]

      desc 'Prepare repository for development of next verion'
      task 'release:after', [:remote] do |_, args|
        if Scm.on_master? || Scm.on_major_version_stable?(config.stable_branch_name)
          Rake.application['release:after:master'].invoke(args[:remote])
        end
      end

      task 'release', [:remote] do |_, args|
        Rake.application['release:after'].invoke(args[:remote])
      end

      task 'bump:patch' => [
        'semmy:versioning:bump_patch_level',
        'semmy:changelog:insert_unreleased_section'
      ]

      task 'bump:major' => [
        'semmy:changelog:replace_minor_stable_branch_with_major_stable_branch',
        'semmy:versioning:bump_major'
      ]
    end
  end
end
