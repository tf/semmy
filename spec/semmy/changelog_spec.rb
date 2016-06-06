require 'spec_helper'

module Semmy
  describe Changelog do
    let(:config) do
      Configuration.new do |c|
        c.changelog_version_section_heading = '## Version %{version}'
        c.changelog_compare_url = '%{homepage}/compare/v%{old_version}..v%{new_version}'
        c.changelog_unrelased_section_heading = '## Changes on master'
        c.changelog_unrelased_section_blank_slate = 'None so far.'
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
                                             old_version: '1.1.0',
                                             new_version: '1.2.0').call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          ## Version 1.2.0

          2016-01-02

          [Compare changes](https://github.com/user/my_gem/compare/v1.1.0..v1.2.0)

          - Something new
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
                                      old_version: '1.1.0',
                                      new_version: '1.2.0').call(contents)
        }.to raise_error(Changelog::InsertPointNotFound)
      end
    end

    describe 'Changelog::InsertUnreleasedSection#call' do
      it 'insert unreleased section before first version section' do
        contents = <<-END.unindent
          # Changelog

          Some text.

          ## Version 1.2.0

          - Something new
        END

        result = Changelog::InsertUnreleasedSection.new(config).call(contents)

        expect(result).to eq(<<-END.unindent)
          # Changelog

          Some text.

          ## Changes on master

          None so far.

          ## Version 1.2.0

          - Something new
        END
      end
    end
  end
end
