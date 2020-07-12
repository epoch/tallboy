# tallboy

Generate pretty **Unicode**, **ASCII** or **Markdown** tables on the terminal for your command line programs. 

[tallboy](https://github.com/epoch/tallboy) is a DSL for quickly creating text based tables in [Crystal](https://crystal-lang.org/).

## Quick start
```crystal
table = Tallboy.table do
  header ["name", "hex"]
  row ["mistyrose",       "#ffe4e1"]
  row ["darkolivegreen",  "#556b2f"]
  row ["papayawhip",      "#ffefd5"]
end

puts table
```
```
┌────────────────┬─────────┐
│ name           │ hex     │
├────────────────┼─────────┤
│ mistyrose      │ #ffe4e1 │
│ darkolivegreen │ #556b2f │
│ papayawhip     │ #ffefd5 │
└────────────────┴─────────┘
```
```crystal
# full API

table = Tallboy.table do
  # define 3 columns. set first column width to 12 & align right 
  columns do 
    add "size", width: 12, align: :right
    add "http method"
    add "path"
  end

  # add header with multiple lines
  header "good\nfood\nhunting", align: :right

  # add header with column span on one cell
  header do
    cell ""
    cell "routes", span: 2
  end
  
  # add header inferred from column definitions
  # [size, http method, path]
  header

  rows [
    ["207 B", "post", "/dishes"],
    ["1.3 kB", "get", "/dishes"],
    ["910 B", "patch", "/dishes/:id"],
    ["10.2 kB", "delete", "/dishes/:id"],
  ]
end

puts table
```
```
┌────────────────────────────────────────┐
│                                   good │
│                                   food │
│                                hunting │
├────────────┬───────────────────────────┤
│            │ routes                    │
├────────────┼─────────────┬─────────────┤
│       size │ http method │ path        │
├────────────┼─────────────┼─────────────┤
│      207 B │ post        │ /dishes     │
│     1.3 kB │ get         │ /dishes     │
│      910 B │ patch       │ /dishes/:id │
│    10.2 kB │ delete      │ /dishes/:id │
└────────────┴─────────────┴─────────────┘

# draw border joints correctly even with different span sizes :)
```

## Top Features

- spanning cells across muliple columns and entire rows
- simple, readable and flexible API
- text alignment (left, right, center)
- set width and alignment for entire columns with column definitions
- static type checking for almost all DSL options
- support multi-line cells with the newline character
- full custom styling or choose from multiple border styles including ascii, unicode and markdown
- render directly into IO for better performance

## Install it as a shard

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  tallboy:
    github: epoch/tallboy
```

2. Run `shards install`

## Simple tutorial

1. create a table with `Tallboy.table`

```crystal
table = Tallboy.table do
end
```

2. define columns. here we will define a 4 column table with `columns`.

```crystal
table = Tallboy.table do
  columns do
    add "id"
    add "name"
    add "description"
    add "price
  end
end
```

3. add rows. you can add single row with `row` or nested arrays with `rows`. values can be **any object that has a `to_s` method**.

```crystal
table = Tallboy.table do
  columns do
    add "id"
    add "name"
    add "description"
    add "price"
  end

  rows [
    [1, "cake", "goes well with pudding", 3.4],
    [2, "pudding", "so good with cake!", 12.5],
    [3, "burger", "from the reburgulator", 22.9],
    [4, "chips", "wait you mean fries?", 5],
  ]
end
```

4. add header. we can manually add header with `header` with arguments or pass no arguments to inferred from column definitions. header is just a row with a border below.

```crystal
table = Tallboy.table do
  columns do
    add "id"
    add "name"
    add "description"
    add "price"
  end

  header
  rows [
    [1, "cake", "goes well with pudding", 3.4],
    [2, "pudding", "so good with cake!", 12.5],
    [3, "burger", "from the reburgulator", 22.9],
    [4, "chips", "wait you mean fries?", 5],
  ]
end
```

5. add footer. we can add footer with `footer`. footer is a row with border on top. If we pass a string instead of an array it will auto span all 4 columns based on the other rows defined in this table. nice! :)

```crystal
table = Tallboy.table do
  columns do
    add "id"
    add "name"
    add "description"
    add "price"
  end
  header
  rows [
    [1, "cake", "goes well with pudding", 3.4],
    [2, "pudding", "so good with cake!", 12.5],
    [3, "burger", "from the reburgulator", 22.9],
    [4, "chips", "wait you mean fries?", 5],
  ]
  footer "43.8"
end
```

6. set column span, widths and aligments. `header`, `row` and `footer` also take blocks. here we can set column span on a cell within the footer.

```crystal
table = Tallboy.table do
  columns do
    add "id"
    add "name"
    add "description"
    add "price"
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
    cell "43.8"
  end
end
```

7. render with different border styles.

```crystal
puts table.render # defaults to unicode
puts table.render(:ascii) # classic look

# markdown does not support column spans and outer edge borders
# turning off top and bottom border with border set to `:none`

table = Tallboy.table(border: :none) do
  header ["name", "hex"]
  row ["mistyrose",       "#ffe4e1"]
  row ["darkolivegreen",  "#556b2f"]
  row ["papayawhip",      "#ffefd5"]
end

puts table.render(:markdown) 
```

```
| name           | hex     |
|----------------|---------|
| mistyrose      | #ffe4e1 |
| darkolivegreen | #556b2f |
| papayawhip     | #ffefd5 |
```

8. tallboy supports rendering into custom IO

```crystal
table.render(IO::Memory.new)

puts(
  Tallboy.table do
    row [1,2,3]
  end
)
```

## How it works

Most components in tallboy can be invoked separately. The design philosophy is inspired by how web browsers renders HTML.

```
┌───────────────────────────────────────────────────────────┐
│                  web browser vs tallboy                   │
├───────────────────────────────────────────────────────────┤
│ HTML ──> Document Object Model ──> render tree ──> pixels │
│ DSL  ──> Table Object Model    ──> render tree ──> text   │
└───────────────────────────────────────────────────────────┘
```

```crystal
data = [
  [1,2,3],
  [4,5,6]
]

# TableBuilder is the DSL that returns an object model
table_object_model = Tallboy::TableBuilder.new do 
  rows(data)
end

min_widths = Tallboy::MinWidthCalculator.new(table_object_model).calculate

# ComputedTableBuilder takes the object model and calculate widths for each cell 
computed_table = Tallboy::ComputedTableBuilder.new(table_object_model).build

# RenderTreeBuilder work out borders, spans and organize into nodes to rendering
render_tree = Tallboy::RenderTreeBuilder.new(computed_table).build

# render into output with unicode border style
output_string = Tallboy::Renderer.new(render_tree).render

```

## API

more examples in the examples folder 

## Contributing

Issues and pull requests are welcome on GitHub at (https://github.com/epoch/tallboy)

- [Daniel Tsui](https://github.com/epoch) - creator and maintainer
