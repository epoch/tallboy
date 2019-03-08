require "../spec_helper"

describe Tallboy::Row::Layout do
  it "is valid layout & column size match" do
    layout = Tallboy::Row::Layout.new(3, [1, 1, 1])
    layout.valid?.should be_true
  end

  it "raise exception" do
    expect_raises(Tallboy::InvalidLayoutException) do
      Tallboy::Row::Layout.new(4, [1, 1, 1])
    end
  end
end
