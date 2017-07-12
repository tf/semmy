require 'spec_helper'

module Semmy
  describe Changelog do
    let(:config) do
      Configuration.new do |c|
        c.changelog_version_section_heading = '## Version %{version}'
        c.compare_url = '%{homepage}/compare/%{old_version_tag}...%{new_version_tag}'
        c.file_url = '%{homepage}/blob/%{branch}/%{path}'
        c.changelog_unrelased_section_heading = '## Changes on master'
        c.changelog_unrelased_section_blank_slate = 'None so far.'
        c.changelog_previous_changes_link = 'See [%{branch} branch](%{url}) for previous changes.'
      end
    end

    describe 'Changelog::CloseSection#call' do
      it 'replaces unreleased changes heading with version heading' do
        contents = <<-END.unindent
          # Changelog

          ## Changes on master

          - Something new
        END

        result = Changelog::CloseSection.new(config,
                                             homepage: 'https://github.com/user/my_gem',
                                             date: Date.new(2016, 1, 2),
                                             version: '1.2.0').call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          ## Version 1.2.0

          2016-01-02

          [Compare changes](https://github.com/user/my_gem/compare/1-1-stable...v1.2.0)

          - Something new
        END
      end

      it 'replaces unreleased changes heading including compare link with version heading' do
        contents = <<-END.unindent
          # Changelog

          ## Changes on master

          [Compare changes](https://github.com/user/my_gem/compare/1-1-stable...master)

          - Something new
        END

        result = Changelog::CloseSection.new(config,
                                             homepage: 'https://github.com/user/my_gem',
                                             date: Date.new(2016, 1, 2),
                                             version: '1.2.0').call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          ## Version 1.2.0

          2016-01-02

          [Compare changes](https://github.com/user/my_gem/compare/1-1-stable...v1.2.0)

          - Something new
        END
      end

      it 'closes patch level section with compare link for previous patch level version' do
        contents = <<-END.unindent
          # Changelog

          ## Changes on master

          - Bug fix

          ## Version 1.2.0

          - Old news
        END

        result = Changelog::CloseSection.new(config,
                                             homepage: 'https://github.com/user/my_gem',
                                             date: Date.new(2016, 1, 2),
                                             version: '1.2.1').call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          ## Version 1.2.1

          2016-01-02

          [Compare changes](https://github.com/user/my_gem/compare/v1.2.0...v1.2.1)

          - Bug fix

          ## Version 1.2.0

          - Old news
        END
      end

      it 'fails if unreleased section heading is not found' do
        contents = <<-END.unindent
          # Changelog

          ## Something else

          - Something new
        END

        expect {
          Changelog::CloseSection.new(config,
                                      homepage: 'https://github.com/user/my_gem',
                                      date: Date.new(2016, 1, 2),
                                      version: '1.2.0').call(contents)
        }.to raise_error(Changelog::InsertPointNotFound)
      end
    end

    describe 'Changelog::UpdateForMinor#call' do
      it 'replaces previous version sections with section for minor' \
         'that includes link to previous stable branch' do
        contents = <<-END.unindent
          # Changelog

          Some text.

          ## Version 1.2.0

          - Something new

          ## Version 1.1.0

          - Something else
        END

        result = Changelog::UpdateForMinor
          .new(config,
               version: '1.3.0',
               homepage: 'https://github.com/user/my_gem').call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          Some text.

          ## Changes on master

          [Compare changes](https://github.com/user/my_gem/compare/1-2-stable...master)

          None so far.

          See [1-2-stable branch](https://github.com/user/my_gem/blob/1-2-stable/CHANGELOG.md) for previous changes.
        END
      end

      it 'fails if version section heading is not found' do
        contents = <<-END.unindent
          # Changelog

          ## Something else

          - Something new
        END

        expect {
          Changelog::UpdateForMinor
            .new(config,
                 version: '1.3.0',
                 homepage: 'https://github.com/user/my_gem')
            .call(contents)
        }.to raise_error(Changelog::InsertPointNotFound)
      end
    end
  end
end
