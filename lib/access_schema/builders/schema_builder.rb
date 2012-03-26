module AccessSchema
  class SchemaBuilder < BasicBuilder

    def self.build(&block)
      builder = new(Schema.new)
      builder.instance_eval(&block)
      Proxy.new(builder.schema)
    end

    def self.build_file(filename)
      builder = new(Schema.new)
      builder.instance_eval(File.read(filename))
      Proxy.new(builder.schema)
    end

    def roles(&block)
      builder = RolesBuilder.new(schema)
      builder.instance_eval(&block)
    end

    def asserts(&block)
      builder = AssertsBuilder.new(schema)
      builder.instance_eval(&block)
    end

    def resource(name, &block)
      resource = Resource.new(name.to_sym)
      builder = ResourceBuilder.new(resource)
      builder.instance_eval(&block)
      schema.add_resource(resource)
    end

  end
end
