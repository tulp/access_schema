module AccessSchema
  class Privilege

    attr_reader :name
    attr_reader :schema

    def initialize(schema, name, roles)
      @schema = schema
      @name = name
      @roles = roles
      @expectations = []
    end

    def add_expectation(expectation)
      @expectations << expectation
    end

    def check(roles, extra_options)
      privileged_roles = @roles & roles
      result = PrivilegeCheckResult.new(privileged_roles)

      if result.positive?
        return result
      end

      @expectations.each do |exp|
        if exp.for?(roles)
          result.add_expectation_result(exp.check(extra_options))
        end
      end

      result
    end

    def to_s
      "#{self.class.name}:#{object_id} name: \"#{@name}\" roles: #{@roles} expectations: #{@expectations}"
    end

  end
end
