module AccessSchema
  class Schema

    attr_reader :roles
    alias :plans :roles

    def initialize
      @roles = []
      @asserts = {}
      @namespaces = {}
    end

    def add_role(role)
      @roles << role
    end

    def add_assert(assert)
      @asserts[assert.name] = assert
    end

    def add_namespace(namespace)
      @namespaces[namespace.name] = namespace
    end

    def allow?(*args)
      require!(*args)
    rescue NotAlowedError => e
      false
    else
      true
    end

    def require!(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      case args[0]
      when String, Symbol
        check!(args[0].to_sym, args[1].to_sym, args[2].to_sym, options)
      else
        check!(args[0].class.name.to_sym, args[1].to_sym, args[2].to_sym, options.merge(:subject => args[0]) )
      end
    end

    private

    def check!(namespace_name, element_name, role, options)

      allowed = for_element(namespace_name, element_name) do |element|
        element.allow?(role) do |expectation|
          check_assert(expectation, options)
        end
      end

      unless allowed
        raise NotAlowedError.new
      else
        true
      end

    end

    def check_assert(expectation, options)
      @asserts[expectation.name].check?(expectation.options.merge(options))
    end

    def for_element(namespace, element)
      ns = namespace.to_sym
      fn = element.to_sym
      allowed = elements_for(ns).any? do |element|
        if element.name == fn
          yield(element)
        end
      end
    end

    def elements_for(namespace)
      @namespaces[namespace].elements
    end

  end
end
