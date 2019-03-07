require "./tallboy"

data = [
  ["restful routes","","",""],
  ["", "routes", "", ""],
  ["CRUD", "HTTP method", "PATH", "notes"],
  ["read", "get", "/products", "list all products"],
  ["read", "get", "/products/:id", "show single \nproduct details"],
  ["read", "get", "/products/new", "new product form"],
  ["read", "get", "/products/:id/new", "edit product form"],
  ["create", "post", "/products", ""],
  ["update", "put", "/products/:id",""]
]


table = Tallboy::Table.new(data)

table.row(0).layout = [4,0,0,0]
table.row(1).layout = [1,2,0,1]

table.row(0).border_bottom = true
table.row(1).border_bottom = true
table.row(2).border_bottom = true

table.row(0).cell(0).align = Tallboy::Align::Right
table.row(1).cell(1).align = Tallboy::Align::Center

puts table.render + "\n"

# data = [
#   ["4/4", "",    "",    ""   ],
#   ["3/4", "",    "",    "1/4"],
#   ["2/4", "",    "2/4", ""   ],
#   ["1/4", "1/4", "1/4", "1/4"]
# ]

data = [
  [4,0,0,0],
  [3,0,0,1],
  [2,0,2,0],
  [1,1,1,1]
]

style = Tallboy::Style.new(padding_size: {3,3})
table = Tallboy::Table.new(data, row_separator: true)

puts table.render + "\n"

table.row(0, layout: [4,0,0,0])
table.row(1, layout: [3,0,0,1])
table.row(2, layout: [2,0,2,0])
# table.row(3, layout: [1,2,0,1])

puts table.render + "\n"

data = [
  ["*", "*", "*"],
  ["*", "", ""],
  ["*", "", ""],
]

style = Tallboy::Style.new(padding_size: { 3, 3 })

style.border_top    = {"╔", "═", "╤", "╗"}
style.separator     = {"║", "─", "┴", "║"}
style.border_bottom = {"╚", "═", "╧", "╝"}
style.row           = {"║", " ", "|", "║"}

table = Tallboy::Table.new(data, row_separator: true, style: style)
table.row 1, layout: [3,0,0]
table.row 2, layout: [3,0,0]

# # table.row 1, layout: [2,0,2,0]
# # table.row 2, layout: [4,0,0,0]
# # table.row 3, layout: [4,0,0,0]

table.column 0, align: Tallboy::Align::Center
table.row(1).cell(2).align = Tallboy::Align::Center
puts table.render





