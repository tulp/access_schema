require 'access_schema/version'
require 'access_schema/exceptions'

require 'access_schema/schema'
require 'access_schema/assert'
require 'access_schema/namespace'
require 'access_schema/element'
require 'access_schema/expectation'

require 'access_schema/builders/basic_builder'
require 'access_schema/builders/roles_builder'
require 'access_schema/builders/asserts_builder'
require 'access_schema/builders/namespace_builder'
require 'access_schema/builders/element_builder'
require 'access_schema/builders/schema_builder'

require 'access_schema/proxy'

module AccessSchema

  def self.build(*args)
    SchemaBuilder.build(*args)
  end

  def self.build_file(*args)
    SchemaBuilder.build_file(*args)
  end

  def self.with_options(schema, options)
    Proxy.new(schema, options)
  end

end
