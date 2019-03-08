# tallboy

Generate pretty ASCII based tables on the terminal for your command line programs. Tallboy is written in Crystal.

```tallboy
┌─────┬─────┬─────┐
│  o  │  o  │  o  │
│─────┴─────┴─────│
│        o        │
│─────────────────│
│        o        │
└─────────────────┘
```

## Top Features

- column span
- text alignment (left, right, center)
- multi-line cells
- preset & custom styling

## You can totally install it as a shard

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  tallboy:
    github: epoch/tallboy
```

2. Run `shards install`

## Super simple to use

The core of the library is the `Tallboy::Table` class. Intended for storing data in a structured tabular form. Once data is stored rendering the table is done through `Table#render`. Every row needs to be of equal size.

```crystal
require "tallboy"

data = [
  ["a","b","c"],
  [ 1 , 2 , 3 ]
]

table = Tallboy::Table.new(data)
puts table.render
```
```
+---+---+---+
| a | b | c |
| 1 | 2 | 3 |
+---+---+---+
```

## Column spanning greatness

Tallboy's key feature is column spanning through row layout. Say you have 4 rows of data and you want the first row to span 4 columns

```crystal
data = [
  ["4/4", "",    "",    ""   ],
  ["3/4", "",    "",    "1/4"],
  ["2/4", "",    "2/4", ""   ],
  ["1/4", "1/4", "1/4", "1/4"]
]

table = Tallboy::Table.new(data)
```
Setting the first cell of the first row to span 4 columns with the layout keyword with an array representing how many columns to span.
```crystal
table.row 0, layout: [4,0,0,0]
```
Setting the first cell of the second row to span 3 columns and last cell to span 1 column 
```crystal
table.row 1, layout: [3,0,0,1]
```
Setting the third row to span 2 and 2. Cells with 0 span have no width and is not rendered
```crystal
table.row 2, layout: [2,0,2,0]

puts table.render(row_separator: true)
```
rendering the above table will get the following output
```
+-----------------------+
| 4/4                   |
+-----------------------+
| 3/4             | 1/4 |
+-----------------+-----+
| 2/4       | 2/4       |
+-----------+-----------+
| 1/4 | 1/4 | 1/4 | 1/4 |
+-----+-----+-----+-----+
```

## table style presets

tallboy comes with 2 presets to render table with ascii characters or unicode characters
```crystal
data = [
  ["a", "b", "c"],
  ["d", "e", "f"]
]

table = Tallboy::Table.new(data)
table.render(:unicode)
```
passing `:unicode` to render to draw a table with unicode characters
```
┌───┬───┬───┐
│ a │ b │ c │
│ d │ e │ f │
└───┴───┴───┘
```
more examples in the examples folder 

## Contributing

1. Fork it (https://github.com/epoch/tallboy/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Daniel Tsui](https://github.com/epoch) - creator and maintainer
