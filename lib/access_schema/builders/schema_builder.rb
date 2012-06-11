module AccessSchema
  class SchemaBuilder < BasicBuilder

    class << self
      def build(&block)
        builder = new(Schema.new)
        builder.instance_eval(&block)
        Proxy.new(builder.schema)
      end

      def build_file(filename)
        builder = new(Schema.new)
        builder.instance_eval(File.read(filename))
        Proxy.new(builder.schema)
      end
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
      resource = schema.build_resource(name)
      builder = ResourceBuilder.new(resource)
      builder.instance_eval(&block)
    end

    def schema
      subject
    end

  end
end
