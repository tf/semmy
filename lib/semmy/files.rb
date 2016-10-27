module Semmy
  module Files
    module_function

    def rewrite(path, update)
      content = File.binread(path)
      updated_content = update.call(content)

      File.open(path, 'wb') do |file|
        file.write(updated_content)
      end
    end

    def rewrite_all(glob, update)
      Dir.glob(glob) do |path|
        rewrite(path, update)
      end
    end
  end
end
