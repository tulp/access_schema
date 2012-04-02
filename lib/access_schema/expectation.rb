module AccessSchema
  class Expectation
    attr_reader :name
    attr_reader :roles
    attr_reader :options

    def initialize(name, roles, options = {})
      @name = name
      @roles = roles
      @options = options
    end

    def for?(roles)
      (@roles & roles).size > 0
    end

  end
end
