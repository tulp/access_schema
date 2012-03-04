module AccessSchema
  class Assert
    attr_reader :name

    def initialize(name, vars = [], &block)
      @name = name
      @block = block
      vars << :subject unless vars.include?(:subject)
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
