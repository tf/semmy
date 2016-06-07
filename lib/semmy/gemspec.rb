module Semmy
  module Gemspec
    extend self

    class NotFound < Error; end

    def gem_name
      specification.name
    end

    def homepage
      specification.homepage
    end

    private

    def specification
      Gem::Specification.load(path)
    end

    def path
      Dir.glob('*.gemspec').first ||
        fail(NotFound, 'Gemspec not found.')
    end
  end
end
