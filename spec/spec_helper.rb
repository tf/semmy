$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'semmy'
require 'rake'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each do |file|
  require(file)
end

Semmy::Shell.silence = true
