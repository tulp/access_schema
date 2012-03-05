module AccessSchema
  class ElementBuilder < BasicBuilder

    def assert(name, roles = [], options = {})
      expectation = Expectation.new(name.to_sym, roles.map(&:to_sym), options)
      schema.add_expectation(expectation)
    end

  end
end
