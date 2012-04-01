require 'rspec'
Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

require 'simplecov'

SimpleCov.start

require 'access_schema'

require 'access_schema/loggers/test_logger'


RSpec.configure do |config|
end

