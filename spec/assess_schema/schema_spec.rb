require 'spec_helper'

describe AccessSchema::Schema, "errors rising" do

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

end

