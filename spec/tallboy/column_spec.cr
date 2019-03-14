require "../spec_helper"

describe Tallboy::Column do
  context "when data are single char strings" do
    data = [
      Tallboy::Cell.new("a"),
      Tallboy::Cell.new("b"),
      Tallboy::Cell.new("c")
    ]
    column = Tallboy::Column.new(data)

    describe "#size" do
      it "returns 3" do
        column.size.should eq(3)
      end
    end

    describe "#map" do
      it "implements enumerable methods" do
        column.map(&.span).should eq([1,1,1])
      end
    end

    describe "#align" do
      it "align all cells in column using setter notation" do
        column.first.align.should eq(Tallboy::Align::Left)
        column.align = :right
        column.first.align.should eq(Tallboy::Align::Right)
        column.cells.last.align.should eq(Tallboy::Align::Right)
      end

      it "align all cells in column using method notation" do
        column.align(:center)
        column.cells.all? { |c| c.align == Tallboy::Align::Center }.should eq true
      end
    end
  end

end