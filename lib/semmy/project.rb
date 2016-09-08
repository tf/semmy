module Semmy
  module Project
    extend self

    def version
      VersionFile.parse_version(File.read(version_file))
    end

    def has_not_yet_imported_locales?
      Dir.glob('config/locales/new/**/*.yml').any?
    end

    private

    def version_file
      VersionFile.find(Gemspec.gem_name)
    end
  end
end
