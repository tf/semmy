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

    describe '.previous_version' do
      it 'can decrement minor version' do
        version = '2.2.0'

        result = VersionString.previous_version(version)

        expect(result).to eq('2.1.0')
      end

      it 'can decrement patch level version' do
        version = '2.2.1'

        result = VersionString.previous_version(version)

        expect(result).to eq('2.2.0')
      end

      it 'fails if minor is zero' do
        version = '2.0.0'

        expect {
          VersionString.previous_version(version)
        }.to raise_error(VersionString::NoPreviousMinor)
      end
    end

    describe '.minor_only' do
      it 'removes patch level version' do
        version = '2.2.0'

        result = VersionString.minor_only(version)

        expect(result).to eq('2.2')
      end
    end

    describe '.components' do
      it 'returns hash of components' do
        version = '2.3.1'

        result = VersionString.components(version)

        expect(result).to eq(major: '2', minor: '3', patch: '1')
      end
    end
  end
end
