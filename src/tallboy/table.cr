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
      data.map { |data| Row.new(data) }
    end

    def validate_data!(data)
      raise InvalidRowSizeException.new if !row_size_valid?(data)
    end

    def row_size_valid?(rows)
      rows.all? { |row| row.size == rows.first.size }
    end

    def row(num)
      rows[num]
    end

    def row(num, layout : Array(Int32))
      row(num).layout = layout
    end

    def row(num, border_bottom : Bool)
      row(num).border_bottom = border_bottom
    end

    def row(range : Range(Int32, Int32), layout : Array(Int32))
      range.map { |n| row(n).layout = layout }
    end

    def row(range : Range(Int32, Int32), border_bottom : Bool)
      range.map { |n| row(n).border_bottom = border_bottom }
    end

    def column_count
      max_elem_size(@rows)
    end

    def column(index)
      Column.new(rows.map { |r| r.cell(index) })
    end

    def column(index, align : Align)
      column(index).map(&.align = align)
    end

    def column_widths : Array(Int32)
      column_count.times.map_with_index do |_, index|
        max_elem_size(column(index))
      end
    end

    def render(style : Style)
      Renderer::Basic.new(self, style).render
    end

    def render(
      preset : Symbol = :ascii,
      row_separator = false,
      padding_size = 1
    )
      style = Style.new(
        charset: Style::PRESET.fetch(preset, Style::PRESET[:ascii]),
        row_separator: row_separator,
        padding_size: padding_size)

      Renderer::Basic.new(self, style).render
    end

    private def max_elem_size(arr)
      arr.map(&.size).max.to_i
    end

    def wrap_text(wrap_by : Symbol, max_line_size : Int32)
      @rows.each do |row|
        row.cells.each { |cell| cell.wrap_text(wrap_by, max_line_size) }
      end
    end
  end
end
