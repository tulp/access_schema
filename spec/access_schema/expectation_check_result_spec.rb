require 'spec_helper'


describe AccessSchema::ExpectationCheckResult do

  it "is not positive when just created" do
    subject.should_not be_positive
  end

  it "is positive when passed expectaion added" do
    subject.add_passed(Object.new)
    subject.should be_positive
  end

  it "is not positive when failed expectation added" do
    subject.add_passed(Object.new)
    subject.add_failed(Object.new)
    subject.should_not be_positive
  end

end
