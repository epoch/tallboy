require "../src/tallboy"

data = [
  ["routing for products", "", "", ""],
  ["", "routes", "", ""],
  ["CRUD", "HTTP method", "Path", "notes"],
  ["read", "get", "/products", "display all products"],
  ["read", "get", "/products/:id", "display a specific product"],
  ["read", "get", "/products/new", "returns an HTML form for \ncreating a product"],
  ["read", "get", "/products/:id/new", "returns an HTML form for \nediting a product"],
  ["create", "post", "/products", "create a new product"],
  ["update", "put", "/products/:id", "update a specific product"],
]

table = Tallboy::Table.new(data)

table.row 0, layout: [4, 0, 0, 0]
table.row 1, layout: [1, 2, 0, 1]

table.row 0..2, border_bottom: true

table.row(0).cell(0).align = :right
table.row(1).cell(1).align = :center

puts table.render + "\n"

# ------------------------------------------------------

data = [
  [4, 0, 0, 0],
  [3, 0, 0, 1],
  [2, 0, 2, 0],
  [1, 1, 1, 1],
]

style = Tallboy::Style.new(padding_size: 2, row_separator: true)
table = Tallboy::Table.new(data)

puts table.render(style: style) + "\n"

table.row 0, layout: [4, 0, 0, 0]
table.row 1, layout: [3, 0, 0, 1]
table.row 2, layout: [2, 0, 2, 0]

puts table.render(style: style) + "\n"

# ------------------------------------------------------

data = [
  ["o", "o", "o"],
  ["o", "", ""],
  ["o", "", ""],
]

table = Tallboy::Table.new(data)

table.row 1..2, layout: [3, 0, 0]

table.row(1).cell(0).align = :center
table.row(2).cell(0).align = :center

puts table.render(:unicode, row_separator: true, padding_size: 2)

data = [
  [1,2,3],
  ["hi", "", ""],
  ["1st", "second", "third"],
  ["number one", "number two", "number three"]
]

table = Tallboy::Table.new(data)
table.row(0).cell(2).align = :right # last cell of first row
table.column(0, align: :right) # align entire first column to right
puts table.render

