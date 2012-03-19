module AccessSchema
  class ConfigBuilder

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def self.build(&block)
      builder = new(Config.new)
      builder.instance_eval(&block)
      builder.config.freeze
    end

    def schema(name, schema)
      if schema.is_a?(Hash)
        schema = schema_from_options(schema)
      end
      @config.add_schema(name, schema)
    end

    def logger(logger)
      puts logger.inspect
      @config.logger = logger
    end

    private

    def schema_from_options(options)

      if options[:file]
        AccessSchema.build_file(options[:file])
      else
        nil
      end

    end

  end
end
