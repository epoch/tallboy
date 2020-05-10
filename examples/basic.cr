require "../temp"

t1 = Tallboy.table do
  columns(true) do
    add "o"
    add "o"
    add "o"
  end
  header "o", align: :center
  header "o", align: :center
end

t2 = Tallboy.table do
  header "header"
  header "sub header"
  header do
    cell "abc\nxyz", span: 2
    cell ""
  end
  row ["data", 12, "data"]
  row ["data", 8, "data"], border: :bottom
  row ["data", 90, "data"]

  row border: :top_bottom do
    cell "x"
    cell "wat", span: 2, align: :right
  end

  row ["data", 3.4, "data"]
  footer "footer"
end

data = [
  [1, "cake", "goes well with pudding"],
  [2, "pudding", "so good with cake!"],
  [3, "burger", "from the reburgulator"],
  [4, "chips", "wait you mean fries?"],
]

t3 = Tallboy.table do
  columns do
    add "id"
    add "dish\nname"
    add "description"
    add "price", align: :right
  end

  header
  rows [
    [1, "cake", "goes well with pudding", 3.4],
    [2, "pudding", "so good with cake!", 12.5],
    [3, "burger", "from the reburgulator", 22.9],
    [4, "chips", "wait you mean fries?", 5],
  ]

  footer do
    cell "total", span: 3
    cell "100"
  end
end

puts t1.render(:ascii)
puts t2
puts t3

min_widths = Tallboy::MinWidthCalculator.new(t3).calculate

computed_table = Tallboy::ComputedTableBuilder.new(t3, min_widths).build

render_tree = Tallboy::RenderTreeBuilder.new(computed_table).build

pp render_tree

puts Tallboy::AsciiRenderer.new(render_tree).render

t4 = Tallboy.table(border: :none) do
  header ["a", "b", "c"]
  row [1,2,3]
  row [4,5,6]
end

puts Tallboy::MarkdownRenderer.new(t4.build).render


table = Tallboy.table do
  # define 3 columns. set first column width to 12 & align right 
  columns do 
    add "size", width: 12, align: :right
    add "http method"
    add "path"
  end

  # add header with multiple lines
  header "good\nfood\nhunting", align: :right

  # add another header with column span on one cell
  header do
    cell ""
    cell "routes", span: 2
  end
  
  # add another header infer from column definitions
  header 

  rows [
    ["207 B", "post", "/dishes"],
    ["1.3 kB", "get", "/dishes"],
    ["910 B", "patch", "/dishes/:id"],
    ["10.2 kB", "delete", "/dishes/:id"],
  ]
end

puts table

