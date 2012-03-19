module AccessSchema

  class TestLogger

    attr_reader :output
    attr_accessor :log_only_level

    %w{debug info warn error fatal}.each do |level|
      define_method(level) do |message = nil, &block|
        return if log_only_level && level != log_only_level
        @output = [@output, message || block.call].compact.join("\n")
      end
    end

  end

end
