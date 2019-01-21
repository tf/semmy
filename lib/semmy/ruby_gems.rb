module Semmy
  module RubyGems
    extend self

    def build_and_test_install
      Shell.sub_process_output(`#{command}`)
      $?.success?
    end

    private

    def command
      "gem build -V #{Gemspec.path} 2>&1 && " \
      "gem install --local #{built_gem_path} 2>&1 && " \
      "gem uninstall -I #{Gemspec.gem_name} -v #{Project.version} 2>&1 && " \
      "rm #{built_gem_path}" \
    end

    def built_gem_path
      [Gemspec.gem_name, '-', Project.version, '.gem'].join
    end
  end
end
