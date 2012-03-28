module AccessSchema
  class RolesBuilder < BasicBuilder

    def role(role)
      schema.add_role(role.to_s)
    end

  end
end
