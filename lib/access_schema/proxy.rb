module AccessSchema
  class Proxy

    def initialize(schema, options = {})
      @schema = schema
      @options = options
    end

    def roles
      @schema.roles
    end

    def plans
      @schema.plans
    end

    def allow?(*args)
      namespace = args[0]
      feature = args[1]

      role, options = case args[2]
      when Symbol, String
        [args[2], args[3]]
      else
        [@options[:role] || @options[:plan], args[2]]
      end

      @schema.allow?(namespace, feature, role, options)
    end

    def require!(*args)
      @schema.require!(*args)
    end

    def with_options(options)
      Proxy.new(@schema, options)
    end

  end
end
