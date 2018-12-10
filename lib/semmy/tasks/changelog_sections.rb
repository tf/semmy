require 'date'

module Semmy
  module Tasks
    class ChangelogSections < Base
      def define
        namespace 'changelog' do
          task 'close_section' do
            version = Project.version
            homepage = Gemspec.homepage

            Shell.info("Inserting #{version} section " \
                       "in #{config.changelog_path}.")

            Files.rewrite(config.changelog_path,
                          Changelog::CloseSection.new(config,
                                                      version: version,
                                                      homepage: homepage,
                                                      date: Date.today))
          end

          task 'update_for_minor' do
            Shell.info('Updating changelog ' \
                       "in #{config.changelog_path}.")

            Files.rewrite(config.changelog_path,
                          Changelog::UpdateForMinor.new(config,
                                                        version: Project.version,
                                                        homepage: Gemspec.homepage))
          end

          task 'replace_minor_stable_branch_with_major_stable_branch' do
            Shell.info('Updating changelog ' \
                       "in #{config.changelog_path}.")

            Files.rewrite(config.changelog_path,
                          Changelog::ReplaceMinorStableBranchWithMajorStableBranch
                            .new(config, version: Project.version))
          end

          task 'insert_unreleased_section' do
            Shell.info('Inserting unreleased changes header ' \
                       "in #{config.changelog_path}.")

            Files.rewrite(config.changelog_path,
                          Changelog::InsertUnreleasedSection.new(config))
          end
        end
      end
    end
  end
end
