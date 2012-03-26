module AccessSchema
  class Resource
    attr_reader :name

    def initialize(name)
      @name = name
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
