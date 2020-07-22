require "../src/tallboy"

t1 = Tallboy.table do
  columns(true) do
    add "o"
    add "o"
    add "o"
  end
  header "o", align: :center
  header "o", align: :center
end

class Text
  def to_s(io)
    io << "text object"
  end
end

class Thing
  def to_s(io)
    io << "thing object"
  end
end

t2 = Tallboy.table do
  header "header"
  header 123
  header do
    cell "abc\nxyz", span: 2
    cell ""
  end
  row [Text.new, Thing.new, "data"], border: :bottom
  row ["data", 90, true]

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

t3 = Tallboy.table(:none) do
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

t4 = Tallboy.table(border: :none) do
  header ["name", "hex"]
  row ["mistyrose",       "#ffe4e1"]
  row ["darkolivegreen",  "#556b2f"]
  row ["papayawhip",      "#ffefd5"]
end

t5 = Tallboy.table do
  row "{"
  row "  \"title\" => \"colors\""
  row "}"
end

puts "\n--- table 1 ----------------------\n\n"
puts t1.render(:ascii)

puts "\n--- table 2 ----------------------\n\n"
puts t2

puts "\n--- table 3 ----------------------\n\n"
puts t3

puts "\n--- table 4 ----------------------\n\n"
puts t4.render(:markdown)

puts "\n--- table 5 ----------------------\n\n"
puts t5

# --- table 1 ----------------------

# +---+---+---+
# | o | o | o |
# +---+---+---+
# |     o     |
# +-----------+
# |     o     |
# +-----------+

# --- table 2 ----------------------

# ┌───────────────────────────────────┐
# │ header                            │
# ├───────────────────────────────────┤
# │ 123                               │
# ├────────────────────────────┬──────┤
# │ abc                        │      │
# │ xyz                        │      │
# ├─────────────┬──────────────┼──────┤
# │ text object │ thing object │ data │
# ├─────────────┼──────────────┼──────┤
# │ data        │ 90           │ true │
# ├─────────────┼──────────────┴──────┤
# │ x           │                 wat │
# ├─────────────┼──────────────┬──────┤
# │ data        │ 3.4          │ data │
# ├─────────────┴──────────────┴──────┤
# │ footer                            │
# └───────────────────────────────────┘

# --- table 3 ----------------------

# │ id    │ dish      │ description            │ price │
# │       │ name      │                        │       │
# ├───────┼───────────┼────────────────────────┼───────┤
# │ 1     │ cake      │ goes well with pudding │   3.4 │
# │ 2     │ pudding   │ so good with cake!     │  12.5 │
# │ 3     │ burger    │ from the reburgulator  │  22.9 │
# │ 4     │ chips     │ wait you mean fries?   │     5 │
# ├───────┴───────────┴────────────────────────┼───────┤
# │ total                                      │   100 │

# --- table 4 ----------------------

# | name           | hex     |
# |----------------|---------|
# | mistyrose      | #ffe4e1 |
# | darkolivegreen | #556b2f |
# | papayawhip     | #ffefd5 |

# --- table 5 ----------------------

# ┌───────────────────────┐
# │ {                     │
# │   "title" => "colors" │
# │ }                     │
# └───────────────────────┘



