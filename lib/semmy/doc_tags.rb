module Semmy
  module DocTags
    UpdateSinceTags = Struct.new(:placeholder, :version) do
      def call(contents)
        contents.gsub("@since #{placeholder}",
                      "@since #{VersionString.minor_only(version)}")
      end
    end
  end
end
