module Semmy
  module Tasks
    class Base
      include Rake::DSL

      attr_reader :config

      def initialize(config = nil)
        @config = config || Configuration.new
        yield(@config) if block_given?

        define
      end

      def define
      end
    end
  end
end
