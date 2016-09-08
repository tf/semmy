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
  end
end
