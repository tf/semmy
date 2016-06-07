module Semmy
  describe VersionFile, fixture_files: true do
    describe '.find' do
      it 'returns path of file in matching lib directory' do
        Fixtures.file('lib/my_gem/version.rb')

        result = VersionFile.find('my_gem')

        expect(result).to eq('lib/my_gem/version.rb')
      end

      it 'returns path of file in nested directories' do
        Fixtures.file('lib/my_gem/plugin/version.rb')

        result = VersionFile.find('my_gem_plugin')

        expect(result).to eq('lib/my_gem/plugin/version.rb')
      end

      it 'handles gem name with hyphens' do
        Fixtures.file('lib/my_gem/plugin/version.rb')

        result = VersionFile.find('my-gem-plugin')

        expect(result).to eq('lib/my_gem/plugin/version.rb')
      end

      it 'handles directory names with hyphens' do
        Fixtures.file('lib/my-gem/version.rb')

        result = VersionFile.find('my-gem')

        expect(result).to eq('lib/my-gem/version.rb')
      end

      it 'fails if no matching version files is found' do
        Fixtures.file('lib/some/other/version.rb')

        expect {
          VersionFile.find('my_gem')
        }.to raise_error(VersionFile::NotFound)
      end
    end

    describe '.parse_version' do
      it 'returns value of version constant' do
        contents = <<-END
          module SomeGem
            VERSION = '2.0.0'
          end
        END

        result = VersionFile.parse_version(contents)

        expect(result).to eq('2.0.0')
      end

      it 'handles unusual spacing' do
        contents = <<-END
          module SomeGem
            VERSION  ='2.0.0'
          end
        END

        result = VersionFile.parse_version(contents)

        expect(result).to eq('2.0.0')
      end

      it 'handles doubles quotes' do
        contents = <<-END
          module SomeGem
            VERSION = "2.0.0"
          end
        END

        result = VersionFile.parse_version(contents)

        expect(result).to eq('2.0.0')
      end

      it 'raises exception if version constant can not be found' do
        contents = <<-END
          module SomeGem
          end
        END

        expect {
          VersionFile.parse_version(contents)
        }.to raise_error(VersionFile::ConstantNotFound)
      end
    end

    describe 'Update#call' do
      it 'replaces version string' do
        contents = <<-END
          module SomeGem
            VERSION = '2.0.0'
          end
        END

        result = VersionFile::Update.new('2.1.0.dev').call(contents)

        expect(result).to include("VERSION = '2.1.0.dev'")
      end

      it 'normalizes unusual spacing' do
        contents = <<-END
          module SomeGem
            VERSION  ='2.0.0'
          end
        END

        result = VersionFile::Update.new('2.1.0.dev').call(contents)

        expect(result).to include("VERSION = '2.1.0.dev'")
      end

      it 'preserves quoting style' do
        contents = <<-END
          module SomeGem
            VERSION = "2.0.0"
          end
        END

        result = VersionFile::Update.new('2.1.0.dev').call(contents)

        expect(result).to include('VERSION = "2.1.0.dev"')
      end

      it 'fails with UpdateFailed error if contents does not match' do
        contents = <<-END
          module SomeGem
          end
        END

        expect {
          VersionFile::Update.new('2.1.0.dev').call(contents)
        }.to raise_error(VersionFile::UpdateFailed)
      end
    end
  end
end
