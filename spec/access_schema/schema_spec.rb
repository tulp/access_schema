require 'spec_helper'

describe AccessSchema::Schema do

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
        @schema.allow? "TestResource", :mark_featured, :invalid
      }.should raise_error(AccessSchema::InvalidRolesError)

      lambda {
        @schema.allow? "TestResource", :mark_featured
      }.should raise_error(AccessSchema::InvalidRolesError)
    end

    it "raises exception on invalid feature"

    it "fails if no roles and asserts are specified in privilege definition" do
      @schema.should_not be_allow("TestResource", :view, [:user])
    end

    it "checks assert if no roles specified in assert definition" do
      @schema.should be_allow("TestResource", :echo_privilege, [:user], :result => true)
      @schema.should_not be_allow("TestResource", :echo_privilege, [:user], :result => false)
    end

  end

  describe "multiple expectations for pass" do

    before do
      @resource = TestResource.new
      @resource.stub(:bananas_count) { @bananas_count }
      @resource.stub(:apples_count) { @apples_count }
    end

    it "passess if all asserts passed" do
      @bananas_count = 1
      @apples_count = 3
      @schema.should be_allow(@resource, :mix, [:bouquet] )
    end

    it "fails if one of assets failed" do
      @bananas_count = 0
      @apples_count = 3
      @schema.should_not be_allow(@resource, :mix, [:bouquet] )

    end

  end

  describe "privilege union for multiple roles" do

    context "when checking privilege :update for TestResource in example schema" do

      it "passes for admin" do
        @schema.should be_allow("TestResource", :update, [:admin])
      end

      it "fails for user" do
        @schema.should_not be_allow("TestResource", :update, [:user])
      end

      it "fails for role 'none'" do
        @schema.should_not be_allow("TestResource", :update, [:none])
      end

      it "passes for admin and user" do
        @schema.should be_allow("TestResource", :update, [:admin, :user])
      end

    end

  end

  describe "dynamic roles calculation" do

    it "accepts proc as roles" do

      lambda {
        roles_calculator = proc { [:admin] }
        @schema.allow? "TestResource", :update, roles_calculator
      }.should_not raise_error

    end

    it "passes options hash with subject into proc" do

      @passed_options = nil
      roles_calculator = proc do |options|
        @passed_options = options
        [:admin]
      end
      subject = TestResource.new
      @schema.allow? subject, :update, roles_calculator, :option1 => :value1
      @passed_options.should be
      @passed_options[:subject].should == subject
      @passed_options[:option1].should == :value1

    end

    it "uses subject from options hash if present" do

      @passed_options = nil
      roles_calculator = proc do |options|
        @passed_options = options
        [:admin]
      end
      subject = TestResource.new
      subject_new = TestResource.new
      @schema.allow? subject, :update, roles_calculator, :subject => subject_new
      @passed_options.should be
      @passed_options[:subject].should == subject_new

    end

    it "passes a copy of options hash" do

      @passed_options = {:option1 => :value1}
      roles_calculator = proc do |options|
        options[:option1] = :changed_value
        [:admin]
      end

      @schema.allow? "TestResource", :update, roles_calculator

      @passed_options[:option1].should == :value1

    end

    it "raises error if none array returned from proc" do

      lambda {
        roles_calculator = proc { :admin }
        @schema.allow? "TestResource", :update, roles_calculator
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
      @schema.allow? "TestResource", :mark_featured, :flower
      pattern = %r/AccessSchema: check PASSED: .+TestResource.+mark_featured.+flower.+AccessSchema::PrivilegeCheckResult/
      @logger.output.should match(pattern)
    end

    it "logs check fail with info level" do
      @logger.log_only_level = "info"
      @schema.allow? "TestResource", :mark_featured, :none
      pattern = %r/AccessSchema: check FAILED: .+TestResource.+mark_featured.+none.+AccessSchema::PrivilegeCheckResult/
      @logger.output.should match(pattern)
    end
  end


end

