require 'spec_helper'


describe AccessSchema::ConfigBuilder do

  it "can define schemas directly from file" do

    config = AccessSchema::ConfigBuilder.build do
      schema :acl, :file => 'spec/schema_example.rb'
    end

    config.schema(:acl).roles.should_not be_nil
  end

  it "can specify logger" do

    test_logger = AccessSchema::TestLogger.new
    config = AccessSchema::ConfigBuilder.build do
      logger test_logger
    end

    config.logger.debug("hello!")

    test_logger.output.should == "AccessSchema: hello!"

  end

end
