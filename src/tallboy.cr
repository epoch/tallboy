require "./tallboy/style"
require "./tallboy/cell"
require "./tallboy/table"
require "./tallboy/renderer"
require "./tallboy/row"
require "./tallboy/row/layout"

module Tallboy
  VERSION = "0.2.0"

  alias CellValue = String | Int::Signed | Int::Unsigned | Float32 | Float64

  class Style
    ASCII = {
      border_top:    {"+", "-", "+", "+"},
      row:           {"|", " ", "|", "|"},
      separator:     {"+", "-", "+", "+"},
      border_bottom: {"+", "-", "+", "+"},
    }

    UNICODE = {
      border_top:    {"┌", "─", "┬", "┐"},
      row:           {"│", " ", "│", "│"},
      separator:     {"│", "─", "┴", "│"},
      border_bottom: {"└", "─", "┴", "┘"},
    }

    PRESET = {
      :ascii   => ASCII,
      :unicode => UNICODE,
    }
  end

  class InvalidRowSizeException < Exception end
  class InvalidLayoutException < Exception end

  enum Align
    Left
    Right
    Center
  end
end
