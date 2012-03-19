module AccessSchema

  class ProxyLogger

    def initialize(logger)
      @logger = logger
    end

    %w{debug info warn error fatal}.each do |level|
      define_method(level) do |message = nil, &block|
        if block
          proxy_block = proc { "AccessSchema: #{block.call}" }
          @logger.send(level, &proxy_block)
        else
          @logger.send(level, "AccessSchema: #{message}")
        end
      end
    end

  end

end
