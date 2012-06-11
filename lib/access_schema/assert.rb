module AccessSchema
  class Assert
    attr_reader :name
    attr_reader :schema

    def initialize(schema, name, vars = [], &block)
      @schema = schema
      @name = name.to_s
      @block = block

      vars = vars.map(&:to_sym)
      vars.push(:subject) unless vars.include?(:subject)

      (class << self; self; end).class_eval do
        vars.each do |name|
          define_method name do
            @options[name]
          end
        end
      end

    end

    def check?(options)
      @options = options
      self.instance_eval(&@block)
    end

  end
end
