require 'spec_helper'

module Semmy
  describe Files, fixture_files: true do
    class StubError < StandardError; end

    describe '.rewrite' do
      it 'replaces contents with result of calling update' do
        file = Fixtures.file('some.rb', 'module A; end')
        update = lambda { |contents| contents.gsub('A', 'B') }

        Files.rewrite('some.rb', update)

        expect(file.read).to eq('module B; end')
      end

      it 'leaves file unchanged if update fails' do
        file = Fixtures.file('some.rb', 'module A; end')
        update = ->(_) { fail(StubError) }

        expect {
          Files.rewrite('some.rb', update)
        }.to raise_error(StubError)

        expect(file.read).to eq('module A; end')
      end
    end

    describe '.rewrite_all' do
      it 'replaces contents with result of calling update in all matching files' do
        file = Fixtures.file('lib/some.rb', 'module A; end')
        update = lambda { |contents| contents.gsub('A', 'B') }

        Files.rewrite_all('**/*.rb', update)

        expect(file.read).to eq('module B; end')
      end

      it 'ignores non matching files' do
        file = Fixtures.file('lib/some.rb', 'module A; end')
        update = lambda { |contents| contents.gsub('A', 'B') }

        Files.rewrite_all('**/*.js', update)

        expect(file.read).to eq('module A; end')
      end
    end
  end
end
