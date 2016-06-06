require 'spec_helper'

module Semmy
  describe Files, fixture_files: true do
    describe '.rewrite' do
      it 'replaces contents with result of calling update' do
        file = Fixtures.file('some.rb', 'module A; end')
        update = lambda { |contents| contents.gsub('A', 'B') }

        Files.rewrite('some.rb', update)

        expect(file.read).to eq('module B; end')
      end
    end
  end
end
