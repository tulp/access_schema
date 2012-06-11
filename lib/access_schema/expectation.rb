module AccessSchema
  class Expectation
    attr_reader :name
    attr_reader :options
    attr_reader :schema

    def initialize(schema, name, options = {})
      @schema = schema
      @name = name
      @options = options
    end

    def passed?(extra_options)
      check_options = options.merge(extra_options)
      assert.check?(check_options)
    end

    def assert
      schema.assert_by_name(name)
    end

  end
end
