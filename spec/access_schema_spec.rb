require 'spec_helper'

describe AccessSchema do

  describe ".build" do
    it "returns schema"
  end

  describe ".build_file" do
    it "returns schema"
  end

  describe ".configure" do
    it "passess given block to ConfigBuilder.build method" do
      block = proc {}
      AccessSchema::ConfigBuilder.should_receive(:build).with(&block)
      AccessSchema.configure(&block)
    end
  end

end
