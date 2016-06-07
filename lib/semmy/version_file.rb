module Semmy
  module VersionFile
    extend self

    class NotFound < Error; end

    class ConstantNotFound < Error; end

    class UpdateFailed < Error; end

    def find(gem_name)
      gem_name_matcher = gem_name.gsub(/[_-]/, '[/_-]')

      Dir.glob('lib/**/version.rb').detect do |file_name|
        file_name =~ %r{lib/#{gem_name_matcher}/version.rb}
      end || fail(NotFound, 'No version file found.')
    end

    def parse_version(contents)
      match = contents.match(/VERSION\s*=\s*['"]([^'"]+)['"]/) ||
        fail(ConstantNotFound, 'Could not find version constant')

      match[1]
    end

    Update = Struct.new(:new_version) do
      def call(contents)
        contents.dup.tap do |result|
          result.gsub!(/VERSION\s*=\s*(['"])[^']+['"]/,
                       "VERSION = \\1#{new_version}\\1") ||
            fail(UpdateFailed,
                 "Could not update version to #{new_version} in\n\n#{contents}\n\n")
        end
      end
    end
  end
end
