module AccessSchema

  class AssertsBuilder < BasicBuilder

    def assert(name, vars = [], &block)
      assert = Assert.new(name.to_sym, vars.map(&:to_sym), &block)
      schema.add_assert(assert)
    end

  end

end
