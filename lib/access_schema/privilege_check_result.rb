module AccessSchema
  class PrivilegeCheckResult

    def initialize(privileged_roles)
      @privileged_roles = privileged_roles || []
      @expectation_results = []
    end

    def add_expectation_result(result)
      @expectation_results << result
    end

    def positive?
      !@privileged_roles.empty? || @expectation_results.any?{|r| r.positive?}
    end

    def negative?
      !positive?
    end

    def to_s
      "#{self.class.name}:#{object_id} privileged_roles: #{@privileged_roles.inspect}, expectation_results: #{@expectation_results}"
    end

  end
end
