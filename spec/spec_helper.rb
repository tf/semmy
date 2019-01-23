$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

require 'semmy'
require 'rake'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each do |file|
  require(file)
end

# This will be the new default in Semmy 2.0
ENV['SEMMY_PUSH_BRANCHES_AFTER_RELEASE'] = 'on'

Semmy::Shell.silence = true
