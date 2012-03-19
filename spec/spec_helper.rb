require 'rspec'
require 'access_schema'

require 'access_schema/loggers/test_logger'

Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|
end

