require 'spec_helper'

module Semmy
  describe Project, fixture_files: true do
    describe '.version' do
      it 'returns parsed version from version file' do
        Fixtures.gemspec(name: 'my_gem', module: 'MyGem')
        Fixtures.version_file('lib/my_gem/version.rb',
                              module: 'MyGem',
                              version: '2.1.0.alpha')

        result = Project.version

        expect(result).to eq('2.1.0.alpha')
      end
    end

    describe '.has_not_yet_imported_locales?' do
      it 'returns false if no config/locales/new/ direcotry is present' do
        result = Project.has_not_yet_imported_locales?

        expect(result).to eq(false)
      end

      it 'returns true if config/locales/new/ files are present' do
        Fixtures.file('config/locales/new/some.yml')
        result = Project.has_not_yet_imported_locales?

        expect(result).to eq(true)
      end

      it 'returns false if only a .gitkeep is present' do
        Fixtures.file('config/locales/new/.gitkeep')
        result = Project.has_not_yet_imported_locales?

        expect(result).to eq(false)
      end
    end
  end
end
