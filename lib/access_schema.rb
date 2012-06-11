require 'access_schema/version'
require 'access_schema/exceptions'

require 'access_schema/config'
require 'access_schema/schema'
require 'access_schema/assert'
require 'access_schema/resource'
require 'access_schema/privilege'
require 'access_schema/privilege_check_result'
require 'access_schema/expectation'
require 'access_schema/expectation_block'
require 'access_schema/expectation_check_result'

require 'access_schema/loggers/proxy_logger'
require 'access_schema/loggers/stub_logger'

require 'access_schema/builders/config_builder'

require 'access_schema/builders/basic_builder'
require 'access_schema/builders/roles_builder'
require 'access_schema/builders/asserts_builder'
require 'access_schema/builders/resource_builder'
require 'access_schema/builders/privilege_builder'
require 'access_schema/builders/schema_builder'

require 'access_schema/proxy'

module AccessSchema

  def self.build(*args)
    SchemaBuilder.build(*args)
  end

  def self.build_file(*args)
    SchemaBuilder.build_file(*args)
  end

  def self.configure(&block)
    @config = ConfigBuilder.build(&block)
  end

  def self.config
    @config ||= Config.new
  end

  def self.schema(name)
    @config.schema(name)
  end

end
