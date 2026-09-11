RSpec.configure do |config|
  config.before(:example) do
    Semmy::Scm.reset
  end
end
