require 'spec_helper'

module Semmy
  describe Gemspec, fixture_files: true do
    describe '.version' do
      it 'returns version from gemspec' do
        Fixtures.gemspec(name: 'my_gem', version: '1.1.0.beta')

        result = Gemspec.version

        expect(result).to eq('1.1.0.beta')
      end

      it 'raises Gemspec::NotFound if no gemspec exists' do
        expect {
          Gemspec.version
        }.to raise_error(Gemspec::NotFound)
      end
    end

    describe '.gem_name' do
      it 'returns name from gemspec' do
        Fixtures.gemspec(name: 'my_gem')

        result = Gemspec.gem_name

        expect(result).to eq('my_gem')
      end
    end
  end
end
