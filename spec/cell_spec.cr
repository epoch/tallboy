require "./spec_helper"

Cell = Tallboy::Cell

describe Cell do
  it "has a size based on value" do
    cell = Cell.new("test")
    cell.size.should eq(4)
  end

  it "size excludes terminal color escape code" do
    cell = Cell.new("\e[31mtest\e[0m")
    cell.size.should eq(4)
  end

  it "size excludes terminal multiple color escape code" do
    cell = Cell.new("\e[31;4mtest\e[0m")
    cell.size.should eq(4)
  end
end