require 'unindent'

module Semmy
  module Changelog
    extend self

    class InsertPointNotFound < Error; end

    CloseSection = Struct.new(:config, :options) do
      def call(contents)
        contents.dup.tap do |result|
          result.gsub!(unreleased_section_matcher,
                       version_header) ||
            fail(InsertPointNotFound, <<-END.unindent)
              Could not find insert point for section heading in:

              #{contents}
            END
        end
      end

      private

      def unreleased_section_matcher
        /#{config.changelog_unrelased_section_heading}(\s*#{compare_link_matcher})?/
      end

      def compare_link_matcher
        # match markdown link of the form [...](...)
        /\[[^\]]+\]\([^)]+\)/
      end

      def version_header
        <<-END.unindent.chomp
          #{version_heading}

          #{current_date}

          #{compare_link_for_versions}
        END
      end

      def version_heading
        config.changelog_version_section_heading % {
          version: options[:new_version]
        }
      end

      def current_date
        options[:date].strftime('%Y-%m-%d')
      end

      def compare_link_for_versions
        Changelog.compare_link(config,
                               homepage: options[:homepage],
                               old_version_tag: old_version_tag,
                               new_version_tag: new_version_tag)
      end

      def old_version_tag
        Changelog.version_tag(options[:old_version])
      end

      def new_version_tag
        Changelog.version_tag(options[:new_version])
      end
    end

    InsertUnreleasedSection = Struct.new(:config, :options) do
      def call(contents)
        insert_before(version_line_matcher,
                      contents,
                      unreleased_section(contents))
      end

      private

      def unreleased_section(contents)
        <<-END.unindent
          #{config.changelog_unrelased_section_heading}

          #{compare_link_for_master(contents)}

          #{config.changelog_unrelased_section_blank_slate}
        END
      end

      def compare_link_for_master(contents)
        Changelog.compare_link(config,
                               homepage: options[:homepage],
                               old_version_tag: last_version_tag(contents),
                               new_version_tag: 'master')
      end

      def last_version_tag(contents)
        match = contents.match(version_line_matcher)
        match && Changelog.version_tag(match[1])
      end

      def version_line_matcher
        Regexp.new(config.changelog_version_section_heading % {
                     version: '([0-9.]+)'
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

    def version_tag(version)
      "v#{version}"
    end

    def compare_link(config, interpolations)
      "[Compare changes](#{compare_url(config, interpolations)})"
    end

    def compare_url(config, interpolations)
      config.changelog_compare_url % interpolations
        .merge(repository: repository_url(config,
                                          interpolations[:homepage]))
    end

    private

    def repository_url(config, homepage)
      if config.github_repository
        "https://github.com/#{config.github_repository}"
      else
        homepage
      end
    end
  end
end
