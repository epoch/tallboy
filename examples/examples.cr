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

table.row(0).cell(0).align = Tallboy::Align::Right
table.row(1).cell(1).align = Tallboy::Align::Center

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

table.row(1).cell(0).align = Tallboy::Align::Center
table.row(2).cell(0).align = Tallboy::Align::Center

puts table.render(:unicode, row_separator: true, padding_size: 2)

