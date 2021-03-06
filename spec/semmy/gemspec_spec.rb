require 'spec_helper'

module Semmy
  describe Gemspec, fixture_files: true do
    describe '.gem_name' do
      it 'returns name from gemspec' do
        Fixtures.gemspec(name: 'my_gem')

        result = Gemspec.gem_name

        expect(result).to eq('my_gem')
      end

      it 'raises Gemspec::NotFound if no gemspec exists' do
        expect {
          Gemspec.gem_name
        }.to raise_error(Gemspec::NotFound)
      end
    end

    describe '.homepage' do
      it 'returns homepage from gemspec' do
        Fixtures.gemspec(name: 'my_gem',
                         homepage: 'https://github.com/user/my_gem')

        result = Gemspec.homepage

        expect(result).to eq('https://github.com/user/my_gem')
      end

      it 'raises Gemspec::NotFound if no gemspec exists' do
        expect {
          Gemspec.homepage
        }.to raise_error(Gemspec::NotFound)
      end
    end

    describe '.path' do
      it 'returns gemspec path' do
        Fixtures.gemspec(name: 'my_gem',
                         homepage: 'https://github.com/user/my_gem')

        result = Gemspec.path

        expect(result).to eq('my_gem.gemspec')
      end

      it 'raises Gemspec::NotFound if no gemspec exists' do
        expect {
          Gemspec.homepage
        }.to raise_error(Gemspec::NotFound)
      end
    end
  end
end
