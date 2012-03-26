module AccessSchema
  class ResourceBuilder < BasicBuilder

    def privilege(name, roles = [], &block)
      privilege = Privilege.new(name.to_sym, roles.map(&:to_sym))
      if block_given?
        builder = PrivilegeBuilder.new(privilege)
        builder.instance_eval(&block)
      end
      schema.add_privilege(privilege)
    end

  end
end
