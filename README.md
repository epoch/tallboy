# tallboy

Generate pretty ASCII based tables on the terminal for your command line programs

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

The core of the library is the `Tallboy::Table` class. Intended for storing data in a structured tabular form. Once data is stored rendering the table is done through `Table#render`

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

Tallboy's key feature is column spanning through row layout. Every row needs to be of equal size.

```crystal
data = [
  ["4/4", "",    "",    ""   ],
  ["3/4", "",    "",    "1/4"],
  ["2/4", "",    "2/4", ""   ],
  ["1/4", "1/4", "1/4", "1/4"]
]

table = Tallboy::Table.new(data)

table.row 0, layout: [4,0,0,0] # first cell spans 4 columns, 0 means no span
table.row 1, layout: [3,0,0,1]
table.row 2, layout: [2,0,2,0]

puts table.render(row_separator: true)
```
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

```crystal
data = [
  ["o", "o", "o"],
  ["o", "o", "o"]
]

table = Tallboy::Table.new(data)
table.render(:unicode)
```
```
┌───┬───┬───┐
│ o │ o │ o │
│ o │ o │ o │
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
