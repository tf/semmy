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
        end
      end
    end
  end
end
