require "../spec_helper"

describe Tallboy::Renderer::Basic do
  it "renders multiline" do
    data = [
      ["a", "b", "c"],
      ["x", " ", " "],
      ["1", "2", "3\n4"],
    ]
    table = Tallboy::Table.new(data)
    table.row(1).layout = [3, 0, 0]
    renderer = Tallboy::Renderer::Basic.new(table)
    renderer.render.chomp.should eq <<-EOF
    +---+---+---+
    | a | b | c |
    | x         |
    | 1 | 2 | 3 |
    |   |   | 4 |
    +---+---+---+
    EOF
  end

  it "renders column span" do
    data = [
      ["apple", "b", "c"],
      ["x", " ", "y"],
      ["1", "2", "34"],
    ]
    table = Tallboy::Table.new(data)
    table.row(1).layout = [2, 0, 1]
    renderer = Tallboy::Renderer::Basic.new(table)
    renderer.calc_cell_width(table.row(0).layout, 0, 1).should eq(5)
    renderer.calc_cell_width(table.row(1).layout, 0, 2).should eq(9)
    renderer.calc_cell_width(table.row(1).layout, 2, 1).should eq(2)
    renderer.render.chomp.should eq <<-EOF
    +-------+---+----+
    | apple | b | c  |
    | x         | y  |
    | 1     | 2 | 34 |
    +-------+---+----+
    EOF
  end

  it "renders rows with separators on every row" do
    data = [
      [1, 2, 3],
      [4, 5, 6],
    ]
    table = Tallboy::Table.new(data)
    style = Tallboy::Style.new(row_separator: true)
    renderer = Tallboy::Renderer::Basic.new(table, style)
    renderer.render.chomp.should eq <<-EOF
    +---+---+---+
    | 1 | 2 | 3 |
    +---+---+---+
    | 4 | 5 | 6 |
    +---+---+---+
    EOF
  end
end
