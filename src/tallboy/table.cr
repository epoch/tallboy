module Tallboy

  class Table
    getter :rows 

    def initialize(
      data : Array(Array(CellValue)), 
      @rows : Array(Row) = [] of Row
    )
      validate_data!(data)
      @rows = build_rows(data)
    end

    def build_rows(data)
      data.map do |data| 
        Row.new(data) 
      end
    end

    def validate_data!(data)
      raise InvalidRowSizeException.new if !row_size_valid?(data)
    end

    def row_size_valid?(rows)
      rows.all? {|row| row.size == rows.first.size }
    end

    def row(num)
      rows[num]
    end

    def row(num, layout)
      row(num).layout = layout
    end

    def column_count
      max_elem_size(@rows)
    end

    def column(index)
      rows.map do |row|
        row.cell(index)
      end
    end

    def column(index, align)
      column(index).map(&.align=align)
    end

    def column_widths : Array(Int32)
      column_count.times.map_with_index do |_, index|
        max_elem_size(column(index))
      end
    end

    private def max_elem_size(arr)
      arr.map(&.size).max
    end

    def render(style : Style = Style.new)
      Renderer::Basic.new(self, style).render
    end

    def render(preset : Symbol = :ascii, row_separator = false)
      style = case preset
      when :unicode
        Style.new(
          border_top:     {"┌", "─", "┬", "┐"},
          separator:      {"│", "─", "┴", "│"},
          border_bottom:  {"└", "─", "┴", "┘"},
          row:            {"│", " ", "│", "│"},
          row_separator: row_separator
        )
      else
        Style.new(row_separator: row_separator)
      end
      Renderer::Basic.new(self, style).render
    end

  end

end
