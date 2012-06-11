module AccessSchema
  class PrivilegeBuilder < BasicBuilder

    def pass(names, roles = [], options = {})

      if roles.is_a?(Array)
        roles = roles.map(&:to_s)
      else
        options = roles
        roles = []
      end

      names = [names] unless names.is_a? Array

      block = ExpectationBlock.new(roles)
      names.each do |name|
        expectation = Expectation.new(subject.schema, name.to_s, options)
        block.add_expectation(expectation)
      end

      subject.add_expectation(block)
    end

  end
end
