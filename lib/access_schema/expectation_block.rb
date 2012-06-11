module AccessSchema
  class ExpectationBlock

    def initialize(roles)
      @roles = roles
      @expectations = []
    end

    def add_expectation(expectation)
      @expectations.push(expectation)
    end

    def for?(roles)
      @roles.empty? || (@roles & roles).size > 0
    end

    def check(extra_options)
      @expectations.inject(ExpectationCheckResult.new) do |r, exp|
        if exp.passed?(extra_options)
          r.add_passed(exp)
        else
          r.add_failed(exp)
        end
        r
      end
    end

  end
end
