module Semmy
  module Tasks
    class ChangelogSections < Base
      def define
        namespace 'changelog' do
          task 'close_section' do
            new_version = Project.version
            old_version = VersionString.previous_minor(new_version)
            homepage = Gemspec.homepage

            Shell.info("Inserting #{new_version} section " \
                       "in #{config.changelog_path}...")

            Files.rewrite(config.changelog_path,
                          Changelog::CloseSection.new(config,
                                                      new_version: new_version,
                                                      old_version: old_version,
                                                      homepage: homepage,
                                                      date: Date.today))
          end

          task 'add_unreleased_section' do
            Shell.info('Inserting unreleased section ' \
                       "in #{config.changelog_path}...")

            Files.rewrite(config.changelog_path,
                          Changelog::InsertUnreleasedSection.new(config))
          end
        end
      end
    end
  end
end
