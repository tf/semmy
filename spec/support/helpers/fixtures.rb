require 'unindent'
require 'fileutils'
require 'git'

module Fixtures
  extend self

  DEFAULT_GEMSPEC_OPTIONS = {
    name: 'test_gem',
    version: '0.0.1',
    homepage: 'http://example.com'
  }

  def file(path, contents = '')
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents.unindent)
    Pathname.new(path)
  end

  def version_file(path, options)
    from_fixture(path, 'version.rb', options)
  end

  def gemspec(options)
    path = "#{options.fetch(:name)}.gemspec"
    template = options.key?(:module) ?
      'gemspec_with_required_version' :
      'gemspec_with_inline_version'

    if options.key?(:module) &&
        Object.constants.include?(options[:module].to_sym)
      Object.send(:remove_const, options[:module].to_sym)
    end

    options[:dependency_statements] =
      if options.key?(:dependency)
        "spec.add_dependency '#{options[:dependency]}', '1.0'"
      else
        ''
      end

    from_fixture(path, template, DEFAULT_GEMSPEC_OPTIONS.merge(options))
  end

  def git_workspace
    Git.init.tap do |git|
      git.config('user.name', 'Test user')
      git.config('user.email', 'test@example.com')
    end
  end

  private

  def from_fixture(path, name, interpolations)
    fixture_path = File.expand_path("../../fixtures/#{name}.tmpl", __FILE__)

    contents = File.read(fixture_path)
    contents = contents % interpolations

    file(path, contents)
  end
end

RSpec.configure do |config|
  config.around(:example, fixture_files: true) do |example|
    Dir.mktmpdir('semmy_spec') do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end

  config.before(:example) do
    Gem::Specification.reset
  end
end
