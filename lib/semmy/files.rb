module Semmy
  module Files
    module_function

    def rewrite(path, update)
      content = File.binread(path)

      File.open(path, 'wb') do |file|
        file.write(update.call(content))
      end
    end

    def rewrite_all(glob, update)
      Dir.glob(glob) do |path|
        rewrite(path, update)
      end
    end
  end
end
