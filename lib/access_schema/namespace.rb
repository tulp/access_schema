module AccessSchema
  class Namespace
    attr_reader :name
    attr_reader :elements

    def initialize(name)
      @name = name
      @elements = []
    end

    def add_element(element)
      @elements << element
    end

  end
end
