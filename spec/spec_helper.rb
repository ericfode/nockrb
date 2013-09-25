require 'RSpec'
require 'guard/rspec'

RSpec.configure do |config|
  config.color_enabled= true
  config.before(:each) do
    @lib_path     = Pathname.new(File.expand_path('../lib/', __FILE__))
  end
end

