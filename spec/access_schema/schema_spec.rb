require 'spec_helper'

describe AccessSchema::Schema, "errors rising" do

  before do
    @schema = AccessSchema::SchemaBuilder.build_file('spec/schema_example.rb')
  end

  describe "#add_role" do

    it "raises error if duplicate"

  end

  describe "#add_assert" do

    it "raises error if duplicate"

  end

  describe "#add_feature" do

    it "raises error if duplicate"
    it "raises error for invalid role"
    it "raises error for invalid assert"

  end

  describe "#allow?" do

    it "raises exception on invalid resource" do
      lambda {
        @schema.allow? "Invalid", :mark_featured, :none
      }.should raise_error(AccessSchema::NoResourceError)
    end

    it "raises exception on invalid role" do
      lambda {
        @schema.allow? "Review", :mark_featured, :invalid
      }.should raise_error(AccessSchema::InvalidRolesError)

      lambda {
        @schema.allow? "Review", :mark_featured
      }.should raise_error(AccessSchema::InvalidRolesError)
    end

    it "raises exception on invalid feature"

  end

  describe "privilege union for multiple roles" do

    context "when checking privilege :update for Review in example schema" do

      it "passes for admin" do
        @schema.should be_allow("Review", :update, [:admin])
      end

      it "fails for user" do
        @schema.should_not be_allow("Review", :update, [:user])
      end

      it "passes for admin and user" do
        @schema.should be_allow("Review", :update, [:admin, :user])
      end

    end

  end

  describe "dynamic roles calculation" do

    it "accepts proc as roles" do

      lambda {
        roles_calculator = proc { [:admin] }
        @schema.allow? "Review", :update, roles_calculator
      }.should_not raise_error

    end

    it "passes options hash with subject into proc" do

      @passed_options = nil
      roles_calculator = proc do |options|
        @passed_options = options
        [:admin]
      end
      subject = Review.new
      @schema.allow? subject, :update, roles_calculator, :option1 => :value1
      @passed_options.should be
      @passed_options[:subject].should == subject
      @passed_options[:option1].should == :value1

    end

    it "passes a copy of options hash" do

      @passed_options = {:option1 => :value1}
      roles_calculator = proc do |options|
        options[:option1] = :changed_value
        [:admin]
      end

      @schema.allow? "Review", :update, roles_calculator

      @passed_options[:option1].should == :value1

    end

    it "raises error if none array returned from proc" do

      lambda {
        roles_calculator = proc { :admin }
        @schema.allow? "Review", :update, roles_calculator
      }.should raise_error(AccessSchema::InvalidRolesError)

    end

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
      @logger.output.should == "AccessSchema: check PASSED: {:resource=>\"Review\", :privilege=>\"mark_featured\", :roles=>[\"flower\"], :options=>{}}"
    end

    it "logs check fail with info level" do
      @logger.log_only_level = "info"
      @schema.allow? "Review", :mark_featured, :none
      @logger.output.should == "AccessSchema: check FAILED: {:resource=>\"Review\", :privilege=>\"mark_featured\", :roles=>[\"none\"], :options=>{}, :failed_asserts=>{}}"
    end
  end


end

