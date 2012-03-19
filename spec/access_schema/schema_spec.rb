require 'spec_helper'

describe AccessSchema::Schema, "errors rising" do

  before do
    @schema = AccessSchema::SchemaBuilder.build_file('spec/schema_example.rb')
  end

  describe "#add_plan" do

    it "raises error if duplicate"

  end

  describe "#add_assert" do

    it "raises error if duplicate"

  end

  describe "#add_feature" do

    it "raises error if duplicate"
    it "raises error for invalid plan"
    it "raises error for invalid assert"

  end

  describe "#allow?" do

    it "raises exception on invalid namespace"
    it "raises exception on invalid feature"

  end

  describe "#require!" do

    it "raises en error is feature is nt allowed"

  end

  describe "logging" do

    before do
      @logger = AccessSchema::TestLogger.new
      AccessSchema.config.logger = @logger
    end

    it "logs check arguments with debug level" do
      @logger.log_only_level = "debug"
      @schema.allow? "Review", :mark_featured, :flower
      @logger.output.should == "AccessSchema: check: namespace = 'Review', privilege = 'mark_featured', roles = '[:flower]', options = '{}'"
    end

    it "logs check fail with info level" do
      @logger.log_only_level = "info"
      @schema.allow? "Review", :mark_featured, :none
      @logger.output.should == "AccessSchema: check FAILED: namespace = 'Review', privilege = 'mark_featured', roles = '[:none]', options = '{}'"
    end
  end


end

