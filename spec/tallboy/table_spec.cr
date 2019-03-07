require "../spec_helper"

describe Tallboy::Table do
  context "when data are single character strings" do
    data = [
      ["a","b","c"],
      ["1","2","3"]
    ]

    table = Tallboy::Table.new(data)

    describe "render" do

      it "generate a table with default borders and padding" do
        table.render.chomp.should eq <<-EOF
        +---+---+---+
        | a | b | c |
        | 1 | 2 | 3 |
        +---+---+---+
        EOF
      end

      it "cell alignment has no observable effect" do
        table.row(0).cell(0).align = Tallboy::Align::Right
        table.render.chomp.should eq <<-EOF
        +---+---+---+
        | a | b | c |
        | 1 | 2 | 3 |
        +---+---+---+
        EOF
      end

      it "generate a table with no padding" do
        style = Tallboy::Style.new(padding_size: 0)
        style.left_padding_size.should eq 0
        style.padding_size.should eq({ 0, 0 })
        table = Tallboy::Table.new(data)
        table.render(style: style).chomp.should eq <<-EOF
        +-+-+-+
        |a|b|c|
        |1|2|3|
        +-+-+-+
        EOF
      end

      it "generate a table with custom character styling" do
        style = Tallboy::Style.new
        style.border_top    = {"╔", "═", "╤", "╗"}
        style.separator     = {"║", "─", "┴", "║"}
        style.border_bottom = {"╚", "═", "╧", "╝"}
        style.row           = {"║", " ", "|", "║"}
        Tallboy::Table.new(data).render(style: style).chomp.should eq <<-EOF
        ╔═══╤═══╤═══╗
        ║ a | b | c ║
        ║ 1 | 2 | 3 ║
        ╚═══╧═══╧═══╝
        EOF
      end
    end

    describe "column" do
      it "returns array of cells" do
        table.column(0).should be_a(Array(Tallboy::Cell))
        table.column(0).first.should be_a(Tallboy::Cell)
      end

      it "with alignment updates alignment for column" do
        table.row(0).cell(1).align.should eq(Tallboy::Align::Left)
        table.column(1, align: Tallboy::Align::Right)
        table.row(0).cell(1).align.should eq(Tallboy::Align::Right)
        table.row(1).cell(1).align.should eq(Tallboy::Align::Right)
      end
    end

    describe "row" do
      it "returns array of cells" do
        table.row(0).first.should be_a(Tallboy::Cell)
      end
    end

  end

  context "when data contain empty strings" do

    data = [
      ["a","" ,"c"],
      ["1","2","" ]
    ]

    it "render generates a table with default borders and padding" do
      Tallboy::Table.new(data).render.chomp.should eq <<-EOF
      +---+---+---+
      | a |   | c |
      | 1 | 2 |   |
      +---+---+---+
      EOF
    end
  end

  context "when data contains different length strings" do

    data = [
      ["1",  "12" ,"123", "1234", "12345"],
      ["123", "1", "1234", "12345", "12"]
    ]

    table = Tallboy::Table.new(data)

    describe "render" do
      it "generates a table with column size to fit content" do
        table.render.chomp.should eq <<-EOF
        +-----+----+------+-------+-------+
        | 1   | 12 | 123  | 1234  | 12345 |
        | 123 | 1  | 1234 | 12345 | 12    |
        +-----+----+------+-------+-------+
        EOF
      end

      it "cell alignment has observable effect" do
        table.row(0).cell(0).align = Tallboy::Align::Right
        table.row(1).cell(4).align = Tallboy::Align::Center
        table.render.chomp.should eq <<-EOF
        +-----+----+------+-------+-------+
        |   1 | 12 | 123  | 1234  | 12345 |
        | 123 | 1  | 1234 | 12345 |   12  |
        +-----+----+------+-------+-------+
        EOF
      end
    end

    describe "column_widths" do 
      it "returns array of column widths" do
        table.column_widths.should eq [3,2,4,5,5]
      end
    end

  end

  describe "layout" do

    data = [
      ["1", "1", "1", "1"],
      ["2", "",  "2", "" ],
      ["3", "",  "",  "1"],
      ["4", "",  "",  "" ]
    ]

    it "generate cells spanning multiple columns" do
      table = Tallboy::Table.new(data)
      table.row 1, layout: [2,0,2,0] 
      table.row 2, layout: [3,0,0,1]
      table.row 3, layout: [4,0,0,0] 
      table.render.chomp.should eq <<-EOF
      +---+---+---+---+
      | 1 | 1 | 1 | 1 |
      | 2     | 2     |
      | 3         | 1 |
      | 4             |
      +---------------+
      EOF
    end
  end

  context "when rows are not equal size" do
    data = [
      ["a","b"],
      ["1","2","3"]
    ]

    describe "new" do
      it "should raise an exception" do
        expect_raises(Tallboy::InvalidRowSizeException) do
          Tallboy::Table.new(data)
        end
      end
    end
  end

  context "when rows are numbers" do
    data = [
      [1,2],
      [3,4]
    ]

    describe "render" do
      it "generates a table with defaults" do
        Tallboy::Table.new(data).render.chomp.should eq <<-EOF
        +---+---+
        | 1 | 2 |
        | 3 | 4 |
        +---+---+
        EOF
      end
    end
  end

end
