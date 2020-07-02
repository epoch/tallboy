require "./spec_helper"

Row = Tallboy::Row

describe Row do
  describe "#cell" do
    it "add 1 cell span 1 part tail" do
      row = Row.new
      row.cell("test") 
      row.cells.first.span.should eq(1)
      row.cells.first.part.should eq(Tallboy::Part::Tail)
    end


    it "span 2 adds 2 cells with part set to body and tail" do
      row = Row.new
      row.cell("test", span: 2)
      row.cells.size.should eq(2)
      row.cells.first.part.should eq(Tallboy::Part::Body)
      row.cells.last.part.should eq(Tallboy::Part::Tail)
    end
  end
end