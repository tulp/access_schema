module AccessSchema
  class SchemaBuilder < BasicBuilder

    def self.build(&block)
      builder = new(Schema.new)
      builder.instance_eval(&block)
      builder.schema.freeze
    end

    def self.build_file(filename)
      builder = new(Schema.new)
      builder.instance_eval(File.read(filename))
      builder.schema.freeze
    end

    def roles(&block)
      builder = RolesBuilder.new(schema)
      builder.instance_eval(&block)
    end

    alias :plans :roles

    def asserts(&block)
      builder = AssertsBuilder.new(schema)
      builder.instance_eval(&block)
    end

    def namespace(name, &block)
      namespace = Namespace.new(name.to_sym)
      builder = NamespaceBuilder.new(namespace)
      builder.instance_eval(&block)
      schema.add_namespace(namespace)
    end

  end
end
