module AccessSchema
  class RolesBuilder < BasicBuilder

    def role(role)
      subject.add_role(role.to_s)
    end

  end
end
