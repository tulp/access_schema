module AccessSchema
  class ExpectationCheckResult

    attr_reader :failed_expectations
    attr_reader :passed_expectations

    def initialize
      @failed_expectations = []
      @passed_expectations = []
    end

    def add_passed(expectation)
      @passed_expectations << expectation
    end

    def add_failed(expectation)
      @failed_expectations << expectation
    end

    def positive?
      @failed_expectations.empty? && !@passed_expectations.empty?
    end

    def negative?
      !positive?
    end

    def to_s
      failed = @failed_expectations.map(&:name)
      passed = @passed_expectations.map(&:name)

      "#{self.class.name}:#{object_id} failed: #{failed}, passed: #{passed}"
    end

  end
end
