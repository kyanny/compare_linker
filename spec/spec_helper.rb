require 'rspec'
require "compare_linker"


Dir["#{__dir__}/support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
  config.include LoadFixtureHelper
end
