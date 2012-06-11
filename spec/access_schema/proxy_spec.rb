require 'spec_helper'

describe AccessSchema::Proxy do

  before do
    @proxy = AccessSchema::Proxy.new(AccessSchema.build_file('spec/schema_example.rb'))
  end

  it "responds to allow? and require!" do
    %w{allow? require!}.should be_all{|m| @proxy.respond_to?(m)}
  end

  describe "#with_options" do

    before do
      @schema = @proxy.with_options(:roles => [:flower], :user_id => 1)
    end

    it "allows to not specify roles for schema calls" do
      @schema.allow?("TestResource", :mark_featured).should be_true
    end

    it "but it accepts roles too" do
      @schema.allow?("TestResource", :mark_featured, :flower).should be_true
      @schema.allow?("TestResource", :mark_featured, :none).should be_false
    end

    it "passes options to schema" do
      @proxy.should_receive(:allow?).with("TestResource", :mark_featured, [:flower], {:user_id => 1})
      @schema.allow?("TestResource", :mark_featured)
    end

  end

end
