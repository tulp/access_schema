require 'spec_helper'


describe AccessSchema::ConfigBuilder do

  it "can define schemas directly from file" do

    config = AccessSchema::ConfigBuilder.build do
      schema :acl, :file => 'spec/schema_example.rb'
    end

    config.schema(:acl).plans.should_not be_nil
  end

end
