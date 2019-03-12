module Tallboy
  module Renderer
    class Basic
      getter :table, :style

      def initialize(@table : Table, @style = Style.new)
      end

      def rows
        table.rows
      end

      def charset
        style.charset
      end

      def render_cell(cell, n, width)
        lpad = charset.row.pad * style.left_padding_size
        rpad = charset.row.pad * style.right_padding_size
        pad_char = charset.row.pad.chars.first
        content = cell.pad_data(cell.lines[n]? || "", width, pad_char)
        "#{lpad}#{content}#{rpad}"
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

      def cells_with_width(row)
        row.map_with_index do |cell, index|
          {cell, calc_cell_width(row.layout, index, cell.span), cell.span}
        end.reject do |_, _, span|
          span < 1
        end
      end

      def render_row(row, style)
        lborder, pad, mid, rborder = style.to_tuple

        cells = cells_with_width(row).map do |cell, width|
          yield cell, width
        end

        "#{lborder}#{cells.join(mid)}#{rborder}\n"
      end

      def separator?(row)
        style.row_separator || row.border_bottom?
      end

      def rows_with_separators(rows)
        rows.reduce("") do |io, row|
          io += row(row, charset.row)
          io += border(row, charset.separator) if separator?(row)
          io
        end
      end

      def render
        String.build do |str|
          str << border(rows.first, charset.border_top)
          str << rows_with_separators(rows[0..-2])
          str << row(rows.last, charset.row)
          str << border(rows.last, charset.border_bottom)
        end
      end
    end
  end
end
