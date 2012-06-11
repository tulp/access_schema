module AccessSchema

  class AssertsBuilder < BasicBuilder

    def assert(name, vars = [], &block)
      subject.build_assert(name, vars, &block)
    end

  end

end
