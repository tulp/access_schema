require 'spec_helper'

describe AccessSchema do

  describe "#build" do
    it "returns schema"
  end

  describe "#build_file" do
    it "returns schema"
  end

  describe "#with_options" do

    before do
      @schema = AccessSchema.build_file('spec/schema_example.rb')
    end

    it "takes schema and options" do
      lambda {
        AccessSchema.with_options(@schema, {:plan => :none})
      }.should_not raise_error
    end

    it "returns schema" do
      result = AccessSchema.with_options(@schema, {:plan => :none})
      %w{allow? require!}.should be_all{|m| result.respond_to?(m)}
    end

    it "allows to not specify plan for schema calls" do
      schema = AccessSchema.with_options(@schema, {:plan => :flower})
      schema.allow?("Review", :mark_featured).should be_true
    end

    it "but it accepts plan too" do
      schema = AccessSchema.with_options(@schema, {})
      schema.allow?("Review", :mark_featured, :flower).should be_true
      schema.allow?("Review", :mark_featured, :none).should be_false
    end

  end

end
