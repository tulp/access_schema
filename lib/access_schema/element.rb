module AccessSchema
  class Element
    attr_reader :name

    def initialize(name, roles, &block)
      @name = name
      @roles = roles
      @block = block
      @expectations = []
    end

    def add_expectation(expectation)
      @expectations << expectation
    end

    def allow?(role)
      @roles.include?(role) || begin
        checklist = @expectations.select { |exp| exp.for?(role) }
        checklist.length > 0 && checklist.all? { |exp| yield(exp) }
      end
    end

  end
end
