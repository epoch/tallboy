require "./spec_helper"

Cell = Tallboy::Cell

describe Cell do
  it "has a size based on value" do
    cell = Cell.new("test")

    cell.size.should eq(4)
  end
end