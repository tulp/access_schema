require 'spec_helper'

describe AccessSchema::SchemaBuilder do

  before do
  end

  it "builds schema from block" do
    @schema = AccessSchema::SchemaBuilder.build do
      roles do
        role :none
      end
    end
    @schema.should be
  end

  it "builds schema from file" do
    @schema = AccessSchema::SchemaBuilder.build_file('spec/schema_example.rb')
    @schema.should be
  end

  it "raises error if file dows not exists" do
    lambda { @schema = AccessSchema::SchemaBuilder.build_file('abc') }.should raise_error
  end

end


class Review; end

describe AccessSchema::SchemaBuilder, "produced schema example" do

  before do
    @review = Review.new
    @review.stub(:photos_count) { @photo_count }
    @schema = AccessSchema::SchemaBuilder.build_file('spec/schema_example.rb')
  end

  it "creates roles" do
    @schema.roles.should ==%w(none bulb flower bouquet admin user)
  end

  context "when checking against role 'none'"  do

    it "does not allows to mark featured" do
      @schema.allow?(@review, :mark_featured, :none).should be_false
    end

    it "allows to add first photo" do
      @photo_count = 0
      @schema.allow?(@review, :add_photo, :none).should be_true
    end

    it "does not allow to add second one" do
      @photo_count = 1
      @schema.allow?(@review, :add_photo, :none).should be_false
    end

  end

  context "when checking against role 'bulb'"  do

    it "does not allow to mark featured" do
      @schema.allow?(@review, :mark_featured, :bulb).should be_false
    end

    it "allows to add up to 5 photos" do
      @photo_count = 4
      @schema.allow?(@review, :add_photo, :bulb).should be_true
    end

    it "does not allow to add more then 5" do
      @photo_count = 5
      @schema.allow?(@review, :add_photo, :bulb).should be_false
    end

  end

  context "when checking against role 'flower'"  do

    it "allows to mark featured" do
      @schema.allow?(@review, :mark_featured, :flower).should be_true
    end

    it "allows to add up to 10 photos" do
      @photo_count = 9
      @schema.allow?(@review, :add_photo, :flower).should be_true
    end

    it "does not allow to add more then 10" do
      @photo_count = 10
      @schema.allow?(@review, :add_photo, :flower).should be_false
    end

  end

  context "when checking against role 'bouquet'"  do

    it "allows to mark featured" do
      @schema.allow?(@review, :mark_featured, :bouquet).should be_true
    end

    it "allows to add over 9000 photos" do
      @photo_count = 9000
      @schema.allow?(@review, :add_photo, :bouquet).should be_true
    end

  end

end
