require 'unindent'

module Semmy
  module Changelog
    class InsertPointNotFound < Error; end

    CloseSection = Struct.new(:config, :options) do
      def call(contents)
        contents.dup.tap do |result|
          result.gsub!(config.changelog_unrelased_section_heading,
                       version_header) ||
            fail(InsertPointNotFound, <<-END.unindent)
              Could not find insert point for section heading in:

              #{contents}
            END
        end
      end

      private

      def version_header
        <<-END.unindent.chomp
          #{version_heading}

          #{current_date}

          #{compare_link}
        END
      end

      def version_heading
        config.changelog_version_section_heading % {version: options[:new_version]}
      end

      def current_date
        options[:date].strftime('%Y-%m-%d')
      end

      def compare_link
        "[Compare changes](#{compare_url})"
      end

      def compare_url
        config.changelog_compare_url % options
      end
    end

    InsertUnreleasedSection = Struct.new(:config) do
      def call(contents)
        insert_before(version_line_matcher,
                      contents,
                      unreleased_section)
      end

      private

      def unreleased_section
        <<-END.unindent
          #{config.changelog_unrelased_section_heading}

          #{config.changelog_unrelased_section_blank_slate}
        END
      end

      def version_line_matcher
        Regexp.new(config.changelog_version_section_heading % {
                     version: '[0-9.]+'
                   })
      end

      def insert_before(line_matcher, text, inserted_text)
        text.dup.tap do |result|
          unless (result.sub!(line_matcher, inserted_text + "\n\\0"))
            fail(InsertPointNotFound,
                 "Insert point not found.")
          end
        end
      end
    end
  end
end
