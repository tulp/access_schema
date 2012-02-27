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
      @config.add_schema(schema)
    end

  end
end
