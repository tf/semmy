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

    describe '.bump_major' do
      it 'increments major version' do
        version = '2.4.0'

        result = VersionString.bump_major(version, 'dev')

        expect(result).to eq('3.0.0.dev')
      end

      it 'resets minor and patch level version' do
        version = '2.4.3'

        result = VersionString.bump_major(version, 'dev')

        expect(result).to eq('3.0.0.dev')
      end

      it 'replaces existing suffix' do
        version = '2.0.0.alpha'

        result = VersionString.bump_major(version, 'dev')

        expect(result).to eq('3.0.0.dev')
      end
    end

    describe '.bump_minor' do
      it 'increments minor version and appends given suffix' do
        version = '2.0.0'

        result = VersionString.bump_minor(version, 'dev')

        expect(result).to eq('2.1.0.dev')
      end

      it 'resets patch level version' do
        version = '2.4.3'

        result = VersionString.bump_minor(version, 'dev')

        expect(result).to eq('2.5.0.dev')
      end

      it 'replaces existing suffix' do
        version = '2.0.0.alpha'

        result = VersionString.bump_minor(version, 'dev')

        expect(result).to eq('2.1.0.dev')
      end
    end

    describe '.bump_patch_level' do
      it 'increments patch level version' do
        version = '2.0.0'

        result = VersionString.bump_patch_level(version)

        expect(result).to eq('2.0.1')
      end

      it 'removes suffix' do
        version = '2.0.0.alpha'

        result = VersionString.bump_patch_level(version)

        expect(result).to eq('2.0.1')
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

    describe '.patch_level?' do
      it 'returns true for patch level version' do
        version = '2.3.1'

        result = VersionString.patch_level?(version)

        expect(result).to eq(true)
      end

      it 'returns false for minor version' do
        version = '2.3.0'

        result = VersionString.patch_level?(version)

        expect(result).to eq(false)
      end

      it 'returns false for major version' do
        version = '2.0.0'

        result = VersionString.patch_level?(version)

        expect(result).to eq(false)
      end
    end

    describe '.previous_stable_branch_name' do
      let(:stable_branch_name_pattern) { '%{major}-%{minor}-stable' }

      it 'returns last stable branch name for minor version' do
        version = '1.2.0'

        result = VersionString.previous_stable_branch_name(version, stable_branch_name_pattern)

        expect(result).to eq('1-1-stable')
      end

      it 'returns last stable branch name for minor version with patch level' do
        version = '1.2.4'

        result = VersionString.previous_stable_branch_name(version, stable_branch_name_pattern)

        expect(result).to eq('1-1-stable')
      end

      it 'returns last major stable branch name for zero minor version' do
        version = '2.0.0'

        result = VersionString.previous_stable_branch_name(version, stable_branch_name_pattern)

        expect(result).to eq('1-x-stable')
      end
    end
  end
end
