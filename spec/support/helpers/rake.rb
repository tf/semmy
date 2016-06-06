RSpec.configure do |config|
  config.before(:example) do
    Rake.application.clear
  end
end
