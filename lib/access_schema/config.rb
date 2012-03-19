module AccessSchema
  class Config

    def initialize
      @schemas = {}
    end

    def add_schema(name, schema)
      @schemas[name] = schema
    end

    def schema(name)
      @schemas[name]
    end

    def logger=(logger)
      @logger = ProxyLogger.new(logger)
    end

    def logger
      @logger ||= StubLogger.new
    end

  end
end
