require 'spec_helper'

module Semmy
  describe DocTags do
    describe 'DocTags::UpdateSinceTags#call' do
      it 'replaces edge with version' do
        contents = <<-END.unindent
          @since edge
          def my_method
          end
        END

        result = DocTags::UpdateSinceTags.new('edge', '1.1.0').call(contents)

        expect(result).to eq(<<-END.unindent)
          @since 1.1
          def my_method
          end
        END
      end
    end
  end
end
