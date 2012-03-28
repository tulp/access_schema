module AccessSchema
  class PrivilegeBuilder < BasicBuilder

    def assert(name, roles = [], options = {})
      expectation = Expectation.new(name.to_s, roles.map(&:to_s), options)
      schema.add_expectation(expectation)
    end

  end
end
