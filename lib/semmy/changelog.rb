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
        /#{config.changelog_unreleased_section_heading}(\s*#{compare_link_matcher})?/
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
          version: version
        }
      end

      def current_date
        options[:date].strftime('%Y-%m-%d')
      end

      def compare_link_for_versions
        Changelog.compare_link(config,
                               homepage: options[:homepage],
                               old_version_tag: old_ref,
                               new_version_tag: Changelog.version_tag(version))
      end

      def old_ref
        if VersionString.patch_level?(version)
          Changelog.version_tag(VersionString.previous_version(version))
        else
          VersionString.previous_stable_branch_name(version, config.stable_branch_name)
        end
      end

      def version
        options[:version]
      end
    end

    UpdateForMinor = Struct.new(:config, :options) do
      def call(contents)
        replace_starting_at(Changelog.version_line_matcher(config),
                            contents,
                            unreleased_section)
      end

      private

      def unreleased_section
        # Once Ruby < 2.3 support is dropped, this can be rewritten
        # as:
        #
        #     <<~END
        #       #{config.changelog_unreleased_section_heading}
        #
        #       #{compare_link_for_master}
        #
        #       #{config.changelog_unreleased_section_blank_slate}
        #
        #       #{link_to_changelog_on_previous_minor_stable_branch}
        #     END
        #
        # `unindent` cannot handle line breaks in interpolated values correctly.
        [
          config.changelog_unreleased_section_heading,
          compare_link_for_master,
          config.changelog_unreleased_section_blank_slate,
          link_to_changelog_on_previous_minor_stable_branch
        ].join("\n\n") << "\n"
      end

      def compare_link_for_master
        Changelog.compare_link(config,
                               homepage: options[:homepage],
                               old_version_tag: previous_stable_branch_name,
                               new_version_tag: 'master')
      end

      def link_to_changelog_on_previous_minor_stable_branch
        config.changelog_previous_changes_link % {
          branch: previous_stable_branch_name,
          url: Changelog.file_url(config,
                                  homepage: options[:homepage],
                                  branch: previous_stable_branch_name)
        }
      end

      def previous_stable_branch_name
        VersionString.previous_stable_branch_name(options[:version],
                                                  config.stable_branch_name)
      end

      def replace_starting_at(line_matcher, text, inserted_text)
        unless text =~ line_matcher
          fail(InsertPointNotFound, 'Insert point not found.')
        end

        [text.split(line_matcher).first, inserted_text].join
      end
    end

    InsertUnreleasedSection = Struct.new(:config) do
      def call(contents)
        insert_before(Changelog.version_line_matcher(config),
                      contents,
                      config.changelog_unreleased_section_heading << "\n")
      end

      private

      def insert_before(line_matcher, text, inserted_text)
        text.dup.tap do |result|
          unless (result.sub!(line_matcher, inserted_text + "\n\\0"))
            fail(InsertPointNotFound,
                 'Insert point not found.')
          end
        end
      end
    end

    ReplaceMinorStableBranchWithMajorStableBranch = Struct.new(:config, :options) do
      def call(contents)
        contents.gsub(minor_stable_branch(options[:version]),
                      major_stable_branch(options[:version]))
      end

      private

      def minor_stable_branch(version)
        VersionString.previous_stable_branch_name(version, config.stable_branch_name)
      end

      def major_stable_branch(version)
        config.stable_branch_name % VersionString.components(version).merge(minor: 'x')
      end
    end

    def version_tag(version)
      "v#{version}"
    end

    def version_line_matcher(config)
      Regexp.new(config.changelog_version_section_heading % {
                   version: '([0-9.]+)'
                 })
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
