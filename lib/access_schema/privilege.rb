module AccessSchema
  class Privilege
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

    def allow?(roles)
      (@roles & roles).size > 0 || begin
        checklist = @expectations.select { |exp| exp.for?(roles) }
        if checklist.length > 0
          checklist.all? { |exp| yield(exp) }
        else
          @roles.empty?
        end
      end
    end

  end
end
