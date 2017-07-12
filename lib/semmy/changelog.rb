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

    UpdateForMinor = Struct.new(:config, :options) do
      def call(contents)
        replace_starting_at(version_line_matcher,
                            contents,
                            unreleased_section)
      end

      private

      def unreleased_section
        <<-END.unindent
          #{config.changelog_unrelased_section_heading}

          #{compare_link_for_master}

          #{config.changelog_unrelased_section_blank_slate}

          #{link_to_changelog_on_previous_minor_stable_branch}
        END
      end

      def compare_link_for_master
        Changelog.compare_link(config,
                               homepage: options[:homepage],
                               old_version_tag: options[:previous_stable_branch],
                               new_version_tag: 'master')
      end

      def link_to_changelog_on_previous_minor_stable_branch
        config.changelog_previous_changes_link % {
          branch: options[:previous_stable_branch],
          url: Changelog.file_url(config,
                                  homepage: options[:homepage],
                                  branch: options[:previous_stable_branch])
        }
      end

      def version_line_matcher
        Regexp.new(config.changelog_version_section_heading % {
                     version: '([0-9.]+)'
                   })
      end

      def replace_starting_at(line_matcher, text, inserted_text)
        unless text =~ line_matcher
          fail(InsertPointNotFound, 'Insert point not found.')
        end

        [text.split(line_matcher).first, inserted_text].join
      end
    end

    def version_tag(version)
      "v#{version}"
    end

    def compare_link(config, interpolations)
      "[Compare changes](#{compare_url(config, interpolations)})"
    end

    def compare_url(config, interpolations)
      config.compare_url % url_interpolations(config, interpolations)
    end

    def file_url(config, interpolations)
      config.file_url % url_interpolations(config, interpolations)
        .merge(path: config.changelog_path)
    end

    private

    def url_interpolations(config, interpolations)
      interpolations.merge(repository: repository_url(config,
                                                      interpolations[:homepage]))
    end

    def repository_url(config, homepage)
      if config.github_repository
        "https://github.com/#{config.github_repository}"
      else
        homepage
      end
    end
  end
end
