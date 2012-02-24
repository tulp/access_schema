module AccessSchema
  class Expectation
    attr_reader :name
    attr_reader :roles
    attr_reader :options

    def initialize(name, roles, options)
      @name = name
      @roles = roles
      @options = options
    end

    def for?(role)
      @roles.include?(role)
    end
  end
end
