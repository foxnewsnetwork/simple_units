$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require "simplecov"
SimpleCov.start
require File.expand_path("../../lib/simple_units", __FILE__)


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.fail_fast = true
end
