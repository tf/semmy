module Semmy
  module Files
    module_function

    def rewrite(file_name, update)
      content = File.binread(file_name)

      File.open(file_name, 'wb') do |file|
        file.write(update.call(content))
      end
    end
  end
end
