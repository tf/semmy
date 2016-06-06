require 'spec_helper'

module Semmy
  describe VersionString do
    describe '.remove_suffix' do
      it 'removes given suffix' do
        version = '2.0.0.dev'

        result = VersionString.remove_suffix(version, 'dev')

        expect(result).to eq('2.0.0')
      end

      it 'fails if suffix is not found' do
        version = '2.0.0.alpha'

        expect {
          VersionString.remove_suffix(version, 'dev')
        }.to raise_error(VersionString::SuffixNotFound)
      end
    end

    describe '.bump_minor' do
      it 'increments minor version and appends given suffix' do
        version = '2.0.0'

        result = VersionString.bump_minor(version, 'dev')

        expect(result).to eq('2.1.0.dev')
      end

      it 'fails if there already is a suffix' do
        version = '2.0.0.alpha'

        expect {
          VersionString.bump_minor(version, 'dev')
        }.to raise_error(VersionString::UnexpectedSuffix)
      end
    end
  end
end
