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
      @schema = @proxy.with_options(:plan => :flower)
    end

    it "allows to not specify plan for schema calls" do
      @schema.allow?("Review", :mark_featured).should be_true
    end

    it "but it accepts plan too" do
      @schema.allow?("Review", :mark_featured, :flower).should be_true
      @schema.allow?("Review", :mark_featured, :none).should be_false
    end

  end

end
