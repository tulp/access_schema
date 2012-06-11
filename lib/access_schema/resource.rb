module AccessSchema
  class Resource
    attr_reader :name
    attr_reader :schema

    def initialize(schema, name)
      @schema = schema
      @name = name.to_s
      @privileges = {}
    end

    def privileges
      @privileges.values
    end

    def add_privilege(privilege)
      @privileges[privilege.name] = privilege
    end

    def get_privilege(name)
      @privileges[name]
    end

  end
end
