module Tallboy
  module Renderer
    class Basic
      getter :table, :style

      def initialize(
        @table : Table, 
        @style = Style.new
        )
      end

      def rows
        table.rows
      end

      def render_cell(cell, n, width)
        lpad = style.row.pad * style.left_padding_size
        rpad = style.row.pad * style.right_padding_size
        if cell.line_exists?(n)
          content = cell.pad_data(cell.lines[n], width, style.row.pad.chars.first)
          "#{lpad}#{content}#{rpad}"
        else
          "#{lpad}#{style.row.pad * width}#{rpad}"
        end
      end

      def calc_cell_width(layout, index, span)
        total_padding_size = (span * style.padding_size.sum) - style.padding_size.sum
        total_separator_size = (span * 1) - 1
        table.column_widths[index, span].sum + total_padding_size + total_separator_size
      end

      def border(row, border)
        lpad = border.pad * style.left_padding_size
        rpad = border.pad * style.right_padding_size

        render_row(row, border) do |cell, width|
          "#{lpad}#{border.pad * width}#{rpad}"
        end
      end

      def row(row, style)
        row.height.times.reduce("") do |io, n|
          io += render_row(row, style) do |cell, width|
            render_cell(cell, n, width)
          end
        end
      end

      def render_row(row, style)
        lborder, pad, mid, rborder = style.to_tuple

        cells = row.map_with_index do |cell, index|
          { cell, calc_cell_width(row.layout, index, cell.span), cell.span }
        end.reject do |cell, width, span|
          span < 1
        end.map do |cell, width|
          yield cell, width
        end

        "#{lborder}#{cells.join(mid)}#{rborder}\n"
      end

      def separator?(row)
        style.row_separator || row.border_bottom?
      end
      
      def rows_with_separators(rows)
        rows.reduce("") do |io, row|
          io += row(row, style.row)
          io += border(row, style.separator) if separator?(row)
          io
        end
      end

      def render
        border(rows.first, style.border_top) +
        rows_with_separators(rows[0..-2]) +
        row(rows.last, style.row) +
        border(rows.last, style.border_bottom)
      end
    end

  end
end