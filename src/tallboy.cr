require "./tallboy/style"
require "./tallboy/style/charset"
require "./tallboy/cell"
require "./tallboy/table"
require "./tallboy/renderer"
require "./tallboy/row"
require "./tallboy/row/layout"

module Tallboy
  VERSION = "0.2.0"

  alias CellValue = String | Int::Signed | Int::Unsigned | Float32 | Float64

  class InvalidRowSizeException < Exception end
  class InvalidLayoutException < Exception end

  enum Align
    Left
    Right
    Center
  end
end
