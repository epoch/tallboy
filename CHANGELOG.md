# Changelog

## Version 0.4.0

- `table#column` now returns a column object containing cells instead of an array of cells. To allow a more consistent api for setting alignment for entire columns. 

```crystal
  table.column(0, align: :center) # this works
  table.column(0).align = :center # can now also do this
  table.column(0).align(:center) # and this
```