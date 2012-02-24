module AccessSchema
  class NamespaceBuilder < BasicBuilder

    def privelege(name, roles, &block)
      element = Element.new(name.to_sym, roles.map(&:to_sym))
      if block_given?
        builder = ElementBuilder.new(element)
        builder.instance_eval(&block)
      end
      schema.add_element(element)
    end

    alias :feature :privelege

  end
end
