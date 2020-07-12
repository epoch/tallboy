require "./computed_table_builder/*"

module Tallboy
  class ComputedTableBuilder
    getter :min_widths

    def initialize(@table : TableBuilder, @min_widths : Array(Int32))
    end

    def build
      ComputedTable.new(build_rows, @table.border)
    end

    def build_rows
      @table.map do |row|
        build_row(row)
      end
    end

    def build_row(row)
      ComputedRow.new(cells_for(row), border: row.border)
    end

    def cells_for(row : Row)
      row.zip(@table.columns.columns, min_widths).map do |(cell, column, min_width)|
        ComputedCell.new(
          cell.value,
          calc_width(column.width, min_width),
          cell.part,
          calc_align(cell.align, column.align)
        )
      end
    end

    def cells_for(row : AutoSpanRow)
      Array(String).new(min_widths.size, row.value)
        .zip(@table.columns.columns, min_widths)
        .map_with_index do |(cell, column, min_width), idx|
          if idx == @table.columns.columns.size - 1
            ComputedCell.new(
              cell, 
              calc_width(column.width, min_width),
              align: calc_align(row.align, column.align)
            )
          else
            ComputedCell.new(
              cell, 
              calc_width(column.width, min_width), 
              :body,
              calc_align(row.align, column.align)
            )
          end
        end
    end

    def calc_width(column_width, min_width)
      case { column_width, min_width }
      when { Int32, Int32 }
        column_width > min_width ? column_width : min_width
      when { WidthOption::Auto, Int32 }
        min_width
      else
        min_width
      end
    end  

    def calc_align(cell_align, column_align)
      case { cell_align, column_align }
      when { Alignment, _ }
        cell_align
      when { AlignOption::Auto, Alignment}
        column_align
      else
        Alignment::Left
      end
    end
  end
end